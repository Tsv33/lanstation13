/mob/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(air_group || (height==0))
		return 1

	if(istype(mover) && mover.checkpass(PASSMOB))
		return 1

	if(ismob(mover))
		var/mob/moving_mob = mover

		if ((other_mobs && moving_mob.other_mobs))
			return 1

	return (!mover.density || !density || lying)

/client/Northeast()
	treat_hotkeys(NORTHEAST)

/client/Southeast()
	treat_hotkeys(SOUTHEAST)

/client/Southwest()
	treat_hotkeys(SOUTHWEST)

/client/Northwest()
	treat_hotkeys(NORTHWEST)

/client/proc/treat_hotkeys(var/keypress)
	keypress = turn(keypress, dir)
	var/mob/living/silicon/pai/pai_override = null
	var/obj/pai_container = null
	if(ispAI(usr))
		var/mob/living/silicon/pai/P = usr
		if(!P.incapacitated())
			if(istype(P.card.loc, /obj))
				pai_container = P.card.loc
				if(pai_container.integratedpai == P.card)
					pai_override = P
	switch(keypress)
		if(NORTHEAST)
			if(pai_override)
				pai_container.swapkey_integrated_pai(pai_override)
				return
			swap_hand()
		if(SOUTHEAST)
			attack_self()
		if(SOUTHWEST)
			if(pai_override)
				pai_container.throwkey_integrated_pai(pai_override)
				return
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.toggle_throw_mode()
			else
				to_chat(usr, "<span class='warning'>This mob type cannot throw items.</span>")
		if(NORTHWEST)
			if(pai_override)
				pai_container.dropkey_integrated_pai(pai_override)
				return
			if(mob.remove_spell_channeling()) //Interrupt to remove spell channeling on dropping
				to_chat(usr, "<span class='notice'>You cease waiting to use your power")
				return
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(!C.get_active_hand())
					to_chat(usr, "<span class='warning'>You have nothing to drop in your hand.</span>")
					return
				if(ishuman(C))
					var/mob/living/carbon/human/H = C
					var/list/borers_in_host = H.get_brain_worms()
					if(borers_in_host && borers_in_host.len) //to allow a host to drop an item at-range mid-extension
						for(var/mob/living/simple_animal/borer/B in borers_in_host)
							var/datum/organ/external/OE = H.get_organ(B.hostlimb)
							if(OE.grasp_id == H.active_hand)
								var/obj/item/weapon/gun/hookshot/flesh/F = B.extend_o_arm
								F.to_be_dropped = H.get_active_hand()
								F.item_overlay = null
				drop_item()
			else if(isMoMMI(usr))
				var/mob/living/silicon/robot/mommi/M = usr
				if(!M.get_active_hand())
					to_chat(M, "<span class='warning'>You have nothing to drop or store.</span>")
					return
				M.uneq_active()
			else if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(!R.module_active)
					return
				R.uneq_active()
			else if(isborer(usr))
				var/mob/living/simple_animal/borer/B = usr
				if(B.host && ishuman(B.host))
					var/mob/living/carbon/human/H = B.host
					var/datum/organ/external/OE = H.get_organ(B.hostlimb) //Borer is occupying an arm
					if(OE.grasp_id)
						if(B.extend_o_arm)
							var/obj/item/weapon/gun/hookshot/flesh/F = B.extend_o_arm
							var/obj/item/held = H.get_held_item_by_index(OE.grasp_id)

							if(held)
								F.to_be_dropped = held
								F.item_overlay = null

							F.attack_self(H)
							H.drop_item(held)
							return
						else
							to_chat(usr, "<span class='warning'>Your host has nothing to drop in [H.gender == FEMALE ? "her" : "his"] [H.get_index_limb_name(OE.grasp_id)].</span>")
			else
				to_chat(usr, "<span class='warning'>This mob type cannot drop items.</span>")

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		to_chat(usr, "<span class='notice'>You are not pulling anything.</span>")
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living/carbon))
		mob:swap_hand()
	if(istype(mob,/mob/living/silicon/robot/mommi))
		return // MoMMIs only have one tool slot.
	if(istype(mob,/mob/living/silicon/robot))//Oh nested logic loops, is there anything you can't do? -Sieve
		var/mob/living/silicon/robot/R = mob
		if(!R.module_active)
			if(!R.module_state_1)
				if(!R.module_state_2)
					if(!R.module_state_3)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3 +a"
						R:module_active = R:module_state_3
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2 +a"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_2
			else
				R:inv1.icon_state = "inv1 +a"
				R:inv2.icon_state = "inv2"
				R:inv3.icon_state = "inv3"
				R:module_active = R:module_state_1
		else
			if(R.module_active == R.module_state_1)
				if(!R.module_state_2)
					if(!R.module_state_3)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3 +a"
						R:module_active = R:module_state_3
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2 +a"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_2
			else if(R.module_active == R.module_state_2)
				if(!R.module_state_3)
					if(!R.module_state_1)
						return
					else
						R:inv1.icon_state = "inv1 +a"
						R:inv2.icon_state = "inv2"
						R:inv3.icon_state = "inv3"
						R:module_active = R:module_state_1
				else
					R:inv1.icon_state = "inv1"
					R:inv2.icon_state = "inv2"
					R:inv3.icon_state = "inv3 +a"
					R:module_active = R:module_state_3
			else if(R.module_active == R.module_state_3)
				if(!R.module_state_1)
					if(!R.module_state_2)
						return
					else
						R:inv1.icon_state = "inv1"
						R:inv2.icon_state = "inv2 +a"
						R:inv3.icon_state = "inv3"
						R:module_active = R:module_state_2
				else
					R:inv1.icon_state = "inv1 +a"
					R:inv2.icon_state = "inv2"
					R:inv3.icon_state = "inv3"
					R:module_active = R:module_state_1
			else
				return
	return



/client/verb/attack_self() //Called when pagedown or Z is pressed
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob))
		mob.drop_item_v()
	return


/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)
				return
			mob.control_object.dir = direct
		else
			mob.control_object.forceMove(get_step(mob.control_object,direct))
	return

/client/proc/Dir_object(direct)
	if(mob && mob.orient_object)
		var/obj/O = mob.orient_object
		O.dir = direct

/client/Move(loc,dir)
	if(move_delayer.next_allowed > world.time)
		return 0

	// /vg/ - Deny clients from moving certain mobs. (Like cluwnes :^)
	if(mob.deny_client_move)
		to_chat(src, "<span class='warning'>You cannot move this mob.</span>")
		return

	if(mob.control_object)
		Move_object(dir)

	if(mob.orient_object)
		Dir_object(dir)
		return

	if(mob.incorporeal_move)
		Process_Incorpmove(dir)
		return

	if(mob.stat == DEAD)
		return

	if(isAI(mob))
		return AIMove(loc,dir,mob)

	if(ispAI(mob))
		var/mob/living/silicon/pai/P = mob
		P.relaymove(dir)
		return

	if(mob.monkeyizing)
		return//This is sota the goto stop mobs from moving var

	if(Process_Grab())
		return

	if(mob.locked_to) //if we're locked_to to something, tell it we moved.
		return mob.locked_to.relaymove(mob, dir)

	if(!mob.canmove)
		return

	//if(istype(mob.loc, /turf/space) || (mob.flags & NOGRAV))
	//	if(!mob.Process_Spacemove(0))	return 0

	// If we're in space or our area has no gravity...
	var/turf/turf_loc = mob.loc
	if(istype(turf_loc) && !turf_loc.has_gravity())
		var/can_move_without_gravity = 0

		// Here, we check to see if the object we're in doesn't need gravity to send relaymove().
		if(istype(mob.loc, /atom/movable))
			var/atom/movable/AM = mob.loc
			if(AM.internal_gravity) // Best name I could come up with, sorry. - N3X
				can_move_without_gravity=1

		// Block relaymove() if needed.
		if(!can_move_without_gravity && !mob.Process_Spacemove(0))
			return 0

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, dir)

	if(isturf(mob.loc))
		if(mob.restrained()) //Why being pulled while cuffed prevents you from moving
			if(mob.grabbed_by.len)
				to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
				return 0
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.incapacitated() && M.canmove && mob.Adjacent(M))
						to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
						return 0
					else
						M.stop_pulling()
			if(mob.tether)
				var/datum/chain/chain_datum = mob.tether.chain_datum
				if(chain_datum.extremity_A == mob)
					if(istype(chain_datum.extremity_B,/mob/living))
						to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
						return 0
				else if(chain_datum.extremity_B == mob)
					if(istype(chain_datum.extremity_A,/mob/living))
						to_chat(src, "<span class='notice'>You're restrained! You can't move!</span>")
						return 0

		if(mob.pinned.len)
			to_chat(src, "<span class='notice'>You're pinned to a wall by [mob.pinned[1]]!</span>")
			return 0

		// COMPLEX MOVE DELAY SHIT
		////////////////////////////
		var/move_delay = 0 // set move delay
		mob.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += 1 + config.run_speed
			if("walk")
				move_delay += 3 + config.walk_speed
		move_delay += mob.movement_delay()

		var/obj/item/weapon/grab/Findgrab = locate() in mob
		if(Findgrab)
			move_delay += 2

		//We are now going to move
		var/old_dir = mob.dir
		move_delay = max(move_delay,1)
		if(mob.movement_speed_modifier)
			move_delay *= (1/mob.movement_speed_modifier)
		mob.delayNextMove(move_delay)
		//Something with pulling things
		if(Findgrab)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((mob.Adjacent(M) || M.loc == mob.loc))
							var/turf/T = mob.loc
							step(mob, dir)
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
				else
					for(var/mob/M in L)
						M.other_mobs = 1
						if(mob != M)
							M.animate_movement = 3
					for(var/mob/M in L)
						spawn( 0 )
							step(M, dir)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else if(mob.confused)
			step_rand(mob)
			mob.last_movement=world.time
		else
			if (prefs.stumble && ((world.time - mob.last_movement) > 5 && move_delay < 2))
				mob.delayNextMove(3)	//if set, delays the second step when a mob starts moving to attempt to make precise high ping movement easier
			//	to_chat(src, "<span class='notice'>First Step</span>")
			step(mob, dir)
			mob.last_movement=world.time

		if(mob.dir != old_dir)
			mob.Facing()

///Process_Grab()
///Called by client/Move()
///Checks to see if you are being grabbed and if so attemps to break it
/client/proc/Process_Grab()
	if(locate(/obj/item/weapon/grab, locate(/obj/item/weapon/grab, mob.grabbed_by.len)))
		var/list/grabbing = list()

		for(var/obj/item/weapon/grab/G in mob.held_items)
			grabbing += G.affecting

		for(var/obj/item/weapon/grab/G in mob.grabbed_by)
			if((G.state == GRAB_PASSIVE)&&(!grabbing.Find(G.assailant)))
				del(G)
			if(G.state == GRAB_AGGRESSIVE)
				mob.delayNextMove(10)
				if(!prob(25))
					return 1
				mob.visible_message("<span class='warning'>[mob] has broken free of [G.assailant]'s grip!</span>",
					drugged_message="<span class='warning'>[mob] has broken free of [G.assailant]'s hug!</span>")
				returnToPool(G)
			if(G.state == GRAB_NECK)
				mob.delayNextMove(10)
				if(!prob(5))
					return 1
				mob.visible_message("<span class='warning'>[mob] has broken free of [G.assailant]'s headlock!</span>",
					drugged_message="<span class='warning'>[mob] has broken free of [G.assailant]'s passionate hug!</span>")
				returnToPool(G)
	return 0


///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)

	switch(mob.incorporeal_move)
		if(INCORPOREAL_GHOST)
			if(isobserver(mob)) //Typecast time
				var/mob/dead/observer/observer = mob
				if(observer.locked_to) //Ghosts can move at any time to unlock themselves (in theory from following a mob)
					observer.manual_stop_follow(observer.locked_to)
			var/turf/T = get_step(mob, direct)
			var/area/A = get_area(T)
			if(A && A.anti_ethereal && !isAdminGhost(mob))
				to_chat(mob, "<span class='sinister'>A dark forcefield prevents you from entering the area.</span>")
			else
				if((T && T.holy) && isobserver(mob) && ((mob.invisibility == 0) || (ticker.mode && (mob.mind in ticker.mode.cult))))
					to_chat(mob, "<span class='warning'>You cannot get past holy grounds while you are in this plane of existence!</span>")
				else
					mob.forceEnter(get_step(mob, direct))
					mob.dir = direct
			if(isobserver(mob))
				var/mob/dead/observer/observer = mob
				mob.delayNextMove(observer.movespeed)
			else
				mob.delayNextMove(1)
		if(INCORPOREAL_NINJA)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				mob.forceMove(locate(locx,locy,mobloc.z))
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, mob.loc))
						anim(T,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
						limit--
						if(limit<=0)
							break
			else
				anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,mob.dir)
				mob.forceEnter(get_step(mob, direct))
			mob.dir = direct
			mob.delayNextMove(1)
		if(INCORPOREAL_ETHEREAL) //Jaunting, without needing to be done through relaymove
			var/turf/newLoc = get_step(mob,direct)
			if(!(newLoc.turf_flags & NOJAUNT))
				mob.forceEnter(newLoc)
				mob.dir = direct
			else
				to_chat(mob, "<span class='warning'>Some strange aura is blocking the way!</span>")
			INVOKE_EVENT(mob.on_moved,list("dir"=direct))
			mob.delayNextMove(2)
			return 1
	// Crossed is always a bit iffy
	for(var/obj/S in mob.loc)
		if(istype(S,/obj/effect/step_trigger) || istype(S,/obj/effect/beam))
			S.Crossed(mob)

	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/Process_Spacemove(var/check_drift = 0,var/ignore_slip = 0)
	//First check to see if we can do things
	if(restrained())
		return 0
	if(flying)
		inertia_dir = 0
		return 1

	if(..())
		//Check to see if we slipped
		if(!ignore_slip && on_foot() && prob(Process_Spaceslipping(5)))
			to_chat(src, "<span class='notice'><B>You slipped!</B></span>")
			src.inertia_dir = src.last_move
			step(src, src.inertia_dir)
			return 0
		return 1

/mob/proc/Process_Spaceslipping(var/prob_slip = 5)
	//Setup slipage
	//If knocked out we might just hit it and stop.  This makes it possible to get dead bodies and such.
	if(stat)
		prob_slip = 0  // Changing this to zero to make it line up with the comment.

	prob_slip = round(prob_slip)
	return(prob_slip)


/mob/proc/Move_Pulled(var/atom/A)
	if(!canmove || restrained() || !pulling)
		return
	if(pulling.anchored)
		return
	if(src.locked_to == pulling)
		return
	if(!pulling.Adjacent(src))
		return
	if(!isturf(pulling.loc))
		return
	if(A == loc && pulling.density)
		return
	if(!Process_Spacemove(,1))
		return
	if(ismob(pulling))
		var/mob/mobpulled = pulling
		var/atom/movable/secondarypull = mobpulled.pulling
		mobpulled.stop_pulling()
		step(mobpulled, get_dir(mobpulled.loc, A))
		if(mobpulled && secondarypull)
			mobpulled.start_pulling(secondarypull)
	else
		step(pulling, get_dir(pulling.loc, A))
	return
