/obj/item/clothing/glasses/scanner
	item_state = "glasses"
	var/on = TRUE
	var/list/color_matrix = null

/obj/item/clothing/glasses/scanner/attack_self()
	toggle()

/obj/item/clothing/glasses/scanner/proc/apply_color(mob/living/carbon/user)	//for altering the color of the wearer's vision while active
	if(color_matrix)
		if(user.client)
			var/client/C = user.client
			C.color =  color_matrix

/obj/item/clothing/glasses/scanner/proc/remove_color(mob/living/carbon/user)
	if(color_matrix)
		if(user.client)
			var/client/C = user.client
			C.color = initial(C.color)

/obj/item/clothing/glasses/scanner/equipped(M as mob, glasses)
	if(istype(M, /mob/living/carbon/monkey))
		var/mob/living/carbon/monkey/O = M
		if(O.glasses != src)
			return
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.glasses != src)
			return
	else
		return
	if(on)
		if(iscarbon(M))
			apply_color(M)

/obj/item/clothing/glasses/scanner/unequipped(mob/user, var/from_slot = null)
	if(from_slot == slot_glasses)
		if(on)
			if(iscarbon(user))
				remove_color(user)

/obj/item/clothing/glasses/scanner/update_icon()
	icon_state = initial(icon_state)

	if (!on)
		icon_state += "off"

/obj/item/clothing/glasses/scanner/verb/toggle()
	set category = "Object"
	set name = "Toggle"
	set src in usr

	var/mob/C = usr
	if (!usr)
		if (!ismob(loc))
			return
		C = loc

	if (C.incapacitated())
		return

	if (on)
		disable(C)

	else
		enable(C)

	update_icon()
	C.update_inv_glasses()

/obj/item/clothing/glasses/scanner/proc/enable(var/mob/C)
	on = TRUE
	to_chat(C, "You turn \the [src] on.")
	if(iscarbon(loc))
		if(istype(loc, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = C
			if(M.glasses && (M.glasses == src))
				apply_color(M)
		else if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(H.glasses && (H.glasses == src))
				apply_color(H)

/obj/item/clothing/glasses/scanner/proc/disable(var/mob/C)
	on = FALSE
	to_chat(C, "You turn \the [src] off.")
	if(iscarbon(loc) && color_matrix)
		if(istype(loc, /mob/living/carbon/monkey))
			var/mob/living/carbon/monkey/M = C
			if(M.glasses && (M.glasses == src))
				remove_color(M)
		else if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = C
			if(H.glasses && (H.glasses == src))
				remove_color(H)

/obj/item/clothing/glasses/scanner/night
	name = "night vision goggles"
	desc = "Agora voc� pode olhar no escuro!"
	icon_state = "night"
	item_state = "glasses"
	origin_tech = Tc_MAGNETS + "=2"
	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
	see_in_dark = 8
	action_button_name = "Toggle Night Vision Goggles"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	eyeprot = -1
	color_matrix = list(0.33,0.33,0.33,0,
						0.33,0.33,0.33,0,
				 		0.33,0.33,0.33,0,
				 		0,0,0,1,
				 		-0.2,0,-0.2,0)

/obj/item/clothing/glasses/scanner/night/enable(var/mob/C)
	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	eyeprot = initial(eyeprot)
	..()

/obj/item/clothing/glasses/scanner/night/disable(var/mob/C)
	see_invisible = 0
	see_in_dark = 0
	eyeprot = 0
	..()

/obj/item/clothing/glasses/scanner/meson
	name = "optical meson scanner"
	desc = "Utilizado para olhar atrav�s de paredes. Tamb�m protege os olhos contra radia��o."
	icon_state = "meson"
	origin_tech = Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=2"
	vision_flags = SEE_TURFS
	eyeprot = -1
	see_invisible = SEE_INVISIBLE_MINIMUM
	action_button_name = "Toggle Meson Scanner"
	species_fit = list(GREY_SHAPED)

/obj/item/clothing/glasses/scanner/meson/enable(var/mob/C)
	eyeprot = 2
	vision_flags |= SEE_TURFS
	see_invisible |= SEE_INVISIBLE_MINIMUM
//	body_parts_covered |= EYES
	..()

/obj/item/clothing/glasses/scanner/meson/disable(var/mob/C)
	eyeprot = 0
//	body_parts_covered &= ~EYES
	vision_flags &= ~SEE_TURFS
	see_invisible &= ~SEE_INVISIBLE_MINIMUM
	..()

/obj/item/clothing/glasses/scanner/material
	name = "optical material scanner"
	desc = "Permite ver o layout original da fia��o e tubula��o da esta��o."
	icon_state = "material"
	origin_tech = Tc_MAGNETS + "=3;" + Tc_ENGINEERING + "=3"
	action_button_name = "Toggle Material Scanner"
	// vision_flags = SEE_OBJS

	var/list/image/showing = list()
	var/mob/viewing

/obj/item/clothing/glasses/scanner/material/enable()
	update_mob(viewing)
	..()

/obj/item/clothing/glasses/scanner/material/disable()
	update_mob(viewing)
	..()

/obj/item/clothing/glasses/scanner/material/update_icon()
	if (!on)
		icon_state = "mesonoff"

	else
		icon_state = initial(icon_state)

/obj/item/clothing/glasses/scanner/material/dropped(var/mob/M)
	update_mob()
	..()

/obj/item/clothing/glasses/scanner/material/unequipped(var/mob/M)
	update_mob()

/obj/item/clothing/glasses/scanner/material/equipped(var/mob/M)
	update_mob(M)

/obj/item/clothing/glasses/scanner/material/OnMobLife(var/mob/living/carbon/human/M)
	update_mob(M.glasses == src ? M : null)

/obj/item/clothing/glasses/scanner/material/proc/clear()
	if (!showing.len)
		return

	if (viewing && viewing.client)
		viewing.client.images -= showing

	showing.Cut()

/obj/item/clothing/glasses/scanner/material/proc/apply()
	if (!viewing || !viewing.client || !on)
		return

	showing = get_images(get_turf(viewing), viewing.client.view)
	viewing.client.images += showing

/obj/item/clothing/glasses/scanner/material/proc/update_mob(var/mob/new_mob)
	if (new_mob == viewing)
		clear()
		apply()
		return

	if (new_mob != viewing)
		clear()

		if (viewing)
			viewing.on_logout.Remove("\ref[src]:mob_logout")
			viewing = null

		if (new_mob)
			new_mob.on_logout.Add(src, "mob_logout")
			viewing = new_mob

/obj/item/clothing/glasses/scanner/material/proc/mob_logout(var/list/args, var/mob/M)
	if (M != viewing)
		return

	clear()
	viewing.on_logout.Remove("\ref[src]:mob_logout")
	viewing = null

/obj/item/clothing/glasses/scanner/material/proc/get_images(var/turf/T, var/view)
	. = list()
	for (var/turf/TT in trange(view, T))
		if (TT.holomap_data)
			. += TT.holomap_data


// Mining Glasses

/obj/item/clothing/glasses/scanner/mining_glasses
	name = "optical ore scanner"
	desc = "Permite detectar min�rios atrav�s das paredes."
	icon_state = "night"
	origin_tech = Tc_ENGINEERING + "=2"
	action_button_name = "Toggle Ore Scanner"
	on = FALSE

	var/delay = 3 SECONDS
	var/last_processed

	var/mob/living/carbon/user

/obj/item/clothing/glasses/scanner/mining_glasses/enable(var/mob/living/carbon/C)
	user = C
	processing_objects.Add(src)
	..()

/obj/item/clothing/glasses/scanner/mining_glasses/disable()
	user = null
	processing_objects.Remove(src)
	..()

/obj/item/clothing/glasses/scanner/mining_glasses/dropped()
	disable()

/obj/item/clothing/glasses/scanner/mining_glasses/process()
	if(!on || !user || !user.client || loc != user)
		disable()
		return null

	if(world.time > last_processed + delay)
		last_processed = world.time

		var/turf/OT = get_turf(user)

		for(var/turf/unsimulated/mineral/R in trange(7, OT))
			if(!R.mineral || istype(R.mineral, /mineral/iron))
				continue
			spawn()
				var/image/I = image('icons/turf/ores.dmi', loc= get_turf(R), icon_state = "rock_[R.mineral.name]", layer = MINERAL_IMAGES_LAYER, dir = R.dir)
				I.plane = BELOWFULLSCREEN_PLANE
				I.alpha = 0
				user.client.images += I
				animate(I, alpha = 150, time = 15)
				animate(alpha = 0, time = 15)
				spawn(30)
					if(user)
						user.client.images -= I
		return TRUE
