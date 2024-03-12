extends Node2D

var cutsceneManager
var daigaEventIncrement = 0
var ralfsEventIncrement = 0
var oskarsEventIncrement = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	cutsceneManager = get_parent().get_node('cutsceneManager')
	
	for unit in get_parent().allUnits:
		if unit.emitDeathSignal == true:
			unit.connect('deathSignal',processDeathTrigger)


func processDeathTrigger(unit):
	#get_parent()._unselectUnit()
	if unit.characterName == 'Graus':
		print('Graus is dead!')
		cutsceneManager.addAction('dialog',{'text':['It seems thou hath nary forgotten thy training, good. Thou wilt have need of it here. . .',
										'My liege, please SPEAK to me, I would hear thy voice that it would be pancaea on an aching mind.',
										'LEFT CLICK the SPEAK action and then LEFT CLICK upon me.'],
								'script':['Benas','Benas','Benas']
								})
	
	
	if unit.characterName == 'Ilga' || unit.characterName == 'Grimnr' || unit.characterName == 'Evalds':
		daigaEventIncrement += 1
	if daigaEventIncrement == 3:
		for daiga in get_parent().allUnits:
			if daiga.characterName == 'Daiga':
				if !daiga.isDead:
					daigaEventIncrement = 0
					cutsceneManager.addAction('dialog',{'text':["Thanks fer gettin' little ol' me outta that scrap there friends. Much as I hate to admit it, my good was cooked, haha!",
														'Of course, thou art much welcome, any whom exhibit such loathsome behavior might as well be put down as dogs.',
														'Er. . . Yeah. . . The way ya speak. Ugh, another noble come to shit on my dinner plate.',
														'I am noble true, and nary do I know what experiences thou hath had of my kind, but I have no interest in opressing thee. Offer me thy bow and let us be rid of this dungeon.',
														"Fine. But I'm off the moment ye start actin' all haughty. Goddit?",
														'Let it be so.'],
											  'script':['Daiga','Heir','Daiga','Heir','Daiga','Heir']})
	
	if unit.characterName == 'Art' || unit.characterName == 'Elze' || unit.characterName == 'Fillip' || unit.characterName == 'Irma':
		ralfsEventIncrement += 1
	if ralfsEventIncrement == 4:
		for ralfs in get_parent().allUnits:
			if ralfs.characterName == 'Ralfs':
				if !ralfs.isDead:
					ralfsEventIncrement = 0
					cutsceneManager.addAction('dialog',
											  {'text':["Huum. . . Spose youll off me too now eh? Lotsa meat ye see, sure I'd last ye quite a while if ye keep me fresh.",
													   "Not unless thou find the vigor to fight with us. 'Tis a shame thy allies were so ready to rush to their demise.",
													   "Allies? Yea, I guess they were eh?",
													   "I'm not so certain. Twas rather as if thee were a tool in their hungry eyes.",
													   "Yea s'always been like that, but jus' cause I ain't seen it don't mean there ain't good in the world eh?",
													   "Quite right friend. Say, I will make thee no honeyed promises that our band is any better than another, but mayhaps thee should join us and see the open sky once more.",
													   "Shouldst thee feel anything less than an equal, thou would always be free to depart. My word.",
													   "Hehe, well ye seem like yer alright. I'll help ye out, this place's gettin' depressing to be honest."],
											  'script':['Ralfs','Heir','Ralfs','Heir','Ralfs','Heir','Heir','Ralfs']})
					ralfs.isPlayer = true
					ralfs.isRecruitable = false
					ralfs.target = null
					ralfs.get_node('visionCone').show()
					ralfs.get_node('radialVision').show()
					for i in range(get_parent().enemyUnits.size() -1, -1, -1):
						if ralfs == get_parent().enemyUnits[i]:
							get_parent().enemyUnits.remove_at(i)
							get_parent().playerUnits.append(ralfs)

	if unit.characterName == 'Admir' || unit.characterName == 'Ljupcho' || unit.characterName == 'Kryspin':
		oskarsEventIncrement += 1
	if oskarsEventIncrement == 3:
		for oskars in get_parent().allUnits:
			if oskars.characterName == 'Oskars':
				if !oskars.isDead:
					oskarsEventIncrement = 0
					cutsceneManager.addAction('dialog',
											  {'text':["Ahh. . . I very much appreciate the aide-- Wait who in the. . ? Could these not be prisoners on the loose?!",
													   "Please, calm thyself sir! We wish not cross arms with thee, rather we came at once to deliver thee from harm.",
													   "But I. . . I must, 'tis my duty. My position as captain of the guard compels me!",
													   "Thy position? Thy position cowing tortured souls in some sick game of preying upon one another? 'Haps thou art our enemy for true. . . ",
													   "Errp. . . Well come at me then, none shall call Oskars a coward!",
													   "Or 'haps the true enemy is they whom preside over this abysmal place. Tell me, ser Oskars, who commands thee?",
													   "Warden Sernas has presided for years! Now have at thee!",
													   "I think not ser Oskars. I, the crown Heir and rightful king now that my father has perished command thee to question this Warden Sernas' vile acts!",
													   "My-My Liege! Forgive this humble no-one, I've spoken out of turn.",
													   "Come Oskars, let us see to it that this place is brought in line."],
											   'script':['Oskars','Heir','Oskars','Heir','Oskars','Heir','Oskars','Heir','Oskars','Heir']})
					oskars.isPlayer = true
					oskars.isRecruitable = false
					oskars.target = null
					oskars.get_node('visionCone').show()
					oskars.get_node('radialVision').show()
					for i in range(get_parent().enemyUnits.size() -1, -1, -1):
						if oskars == get_parent().enemyUnits[i]:
							get_parent().enemyUnits.remove_at(i)
							get_parent().playerUnits.append(oskars)