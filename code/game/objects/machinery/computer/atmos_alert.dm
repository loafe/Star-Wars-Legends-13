/obj/machinery/computer/atmos_alert
	name = "Atmospheric Alert Computer"
	desc = "Used to access the station's atmospheric sensors."
	circuit = "/obj/item/circuitboard/computer/atmos_alert"
	icon_state = "alert:0"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = 1437
	var/datum/radio_frequency/radio_connection


/obj/machinery/computer/atmos_alert/Initialize()
	. = ..()
	set_frequency(receive_frequency)

/obj/machinery/computer/atmos_alert/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]

	if(!zone || !severity) return

	minor_alarms -= zone
	priority_alarms -= zone
	if(severity=="severe")
		priority_alarms += zone
	else if (severity=="minor")
		minor_alarms += zone
	update_icon()
	return


/obj/machinery/computer/atmos_alert/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, receive_frequency)
	receive_frequency = new_frequency
	radio_connection = SSradio.add_object(src, receive_frequency, RADIO_ATMOSIA)


/obj/machinery/computer/atmos_alert/interact(mob/user)
	. = ..()
	if(.)
		return

	var/datum/browser/popup = new(user, "computer", "<div align='center'>Atmos Alert</div>")
	popup.set_content(return_text())
	popup.open()


/obj/machinery/computer/atmos_alert/process()
	if(..())
		src.updateUsrDialog()

/obj/machinery/computer/atmos_alert/update_icon()
	..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(priority_alarms.len)
		icon_state = "alert:2"

	else if(minor_alarms.len)
		icon_state = "alert:1"

	else
		icon_state = "alert:0"
	return


/obj/machinery/computer/atmos_alert/proc/return_text()
	var/priority_text
	var/minor_text

	if(priority_alarms.len)
		for(var/zone in priority_alarms)
			priority_text += "<FONT color='red'><B>[zone]</B></FONT>  <A href='?src=\ref[src];priority_clear=[ckey(zone)]'>X</A><BR>"
	else
		priority_text = "No priority alerts detected.<BR>"

	if(minor_alarms.len)
		for(var/zone in minor_alarms)
			minor_text += "<B>[zone]</B>  <A href='?src=\ref[src];minor_clear=[ckey(zone)]'>X</A><BR>"
	else
		minor_text = "No minor alerts detected.<BR>"

	var/output = {"<B>[name]</B><HR>
<B>Priority Alerts:</B><BR>
[priority_text]
<BR>
<HR>
<B>Minor Alerts:</B><BR>
[minor_text]
<BR>"}

	return output


/obj/machinery/computer/atmos_alert/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["priority_clear"])
		var/removing_zone = href_list["priority_clear"]
		for(var/zone in priority_alarms)
			if(ckey(zone) == removing_zone)
				priority_alarms -= zone

	if(href_list["minor_clear"])
		var/removing_zone = href_list["minor_clear"]
		for(var/zone in minor_alarms)
			if(ckey(zone) == removing_zone)
				minor_alarms -= zone

	update_icon()
	return
