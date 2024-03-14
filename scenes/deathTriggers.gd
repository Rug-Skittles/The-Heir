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


func checkAlive(unit):
	for item in get_parent().playerUnits:
		if item.characterName == unit:
			if !item.isDead:
				return true
			else:
				return false

func processDeathTrigger(unit):
	#get_parent()._unselectUnit()
	if unit.characterName == 'Vrikolaz' and unit.isPlayer:
		cutsceneManager.addAction('dialog',{'text':['Daddy! Noooo!!!!','We were supposed to get back to mom, together. . .','How could this happen. . ?',"I'll make them pay!!!"],
											'script':['Jalena','Jalena','Jalena','Jalena']})
		cutsceneManager.addAction('statChange',{'character':'Jalena','statToChange':'might','value':2})
		cutsceneManager.addAction('statChange',{'character':'Jalena','statToChange':'survival','value':-1})
		
	if unit.characterName == 'Graus':
		get_parent().get_node('unitBox').show()
		print('Graus is dead!')
		cutsceneManager.addAction('dialog',{'text':['It seems thou hath nary forgotten thy training, good. Thou wilt have need of it here. . .',
										'My liege, please SPEAK to me, I would hear thy voice that it would be pancaea on an aching mind.',
										'LEFT CLICK the SPEAK action and then LEFT CLICK upon me. If thou canst see me, use the MOUSE WEEL to rotate thy vision.'],
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

	if unit.characterName == 'Sernas':
		for enemy in get_parent().enemyUnits:
			if enemy.characterName != 'Sernas':
				enemy.process_mode = PROCESS_MODE_DISABLED
		cutsceneManager.addAction('dialog',
								{'text':['Grllk. . . Urrk. . . W-What did I do wrong?',
										'I only ever followed my heart. . .',
										'Thy heart was black and vile, be glad we hath cut it out for thee.',
										'Ghehe. . . Thou want spite? This key is the only that will open that door. . .',
										'Be not a fool Sernas, hand it to me, now!',
										'Squeal piglet, squeal!'],
								'script':['Sernas','Sernas','Heir', 'Sernas','Heir','Sernas']})
		cutsceneManager.addAction('movement',
								{'character':'Sernas',
								'destination':Vector2(915,5598),
								'speed':255})
		cutsceneManager.addAction('toggleFlag',{'character':'Sernas', 'flag':'canDie'})
		cutsceneManager.addAction('modulate',{'character':'Sernas','color':Color(0,0,0,0),'duration':3})
		cutsceneManager.addAction('dialog',
								{'text':['Confound it all! A blighted villain to the end.'],
								'script':['Heir']})
		if checkAlive('Benas'):
			cutsceneManager.addAction('dialog',
									{'text':['My liege. . . Suffice it to say that threshold is solid iron, and yet more gates lay beyond.',
											'And soldiers just as well, no doubt loyal to that usurper for now.'],
									'script':['Benas','Heir']})
		else:
			cutsceneManager.addAction('dialog',
						{'text':['Such a threshold, couldst we find a way through? And shouldst we, wilt yet more dungeon lay beyond?'],
						'script':['Heir']})
		if checkAlive('Ralfs'):
			cutsceneManager.addAction('dialog',
						{'text':['Dare I say that nary even Ralfs with their prodigious body could collapse this door',
								"Aye, looks to be outta my league boss. Sorry 'bout that."],
						'script':['Heir','Ralfs']})
		if checkAlive('Daiga') and checkAlive('Oskars'):
			cutsceneManager.addAction('dialog',
						{'text':["Let's wait it out and ambush the next party that comes through eh? Surely ye can't have but ONE key to the place.",
								"Afraid so friend. Only the warden carries the dungeon keys, and now they art lost to the abyss. . .",
								"Utterly stupid!"],
						'script':['Daiga','Oskars','Daiga']})
		else:
			cutsceneManager.addAction('dialog',
						{'text':['Who can say how long we may have to lay in wait for these doors to open. An eternity mayhaps. . .'],
						'script':['Heir']})
		cutsceneManager.addAction('dialog',
						{'text':['And what of this tunnel? Doth any know its terminus?'],
						'script':['Heir']})
		if checkAlive('Akvile'):
			cutsceneManager.addAction('dialog',
						{'text':["I have yet to hear an echo of the heavy one's demise. . ."],
						'script':['Akvile']})
		if checkAlive('Oskars'):
			cutsceneManager.addAction('dialog',
							{'text':['If I am not mistaken my liege, ruinous constructs of old run deep below.', 'Ruinous constructs?', 'Of time begotten, mayhaps before this land was known by its current name.'],
							'script':['Oskars','Heir','Oskars']})
		if checkAlive('Benas'):
			cutsceneManager.addAction('dialog',
						{'text':["This land is built upon a great natural cavern from whence we source much of our water. 'Haps 'tis drop off therein?"],
						'script':['Benas']})
		if get_parent().playerUnits.size() == 1:
			cutsceneManager.addAction('dialog',
							{'text':["'Twould seem I am to make a decision of mine own."],
							'script':['Heir']})
		else:
			cutsceneManager.addAction('dialog',
						{'text':['Let us commune friends, hath thee thoughts for how we shouldst proceed?'],
						'script':['Heir']})
		if checkAlive('Jalena'):
			cutsceneManager.addAction('dialog',
						{'text':['I saw plenty of rope and chain on my way in here. We could get it all together and go spelunking!'],
						'script':['Jalena']})
		if checkAlive('Ignas'):
			cutsceneManager.addAction('dialog',
						{'text':['Whatever lay down in such portal shouldst stay right well put. I would not climb down there, nor would I recommend we all do so.',
								'Would thee rather wait it out?',
								'Well. . . Yes, I WAS quite comfortable in mine alcove before thee and thine appeared.',
								'Thou art welcome to stay, shouldst we locate the key we will find you whence we return.',
								'Well. . . Thee do have need of a proper surgeon, suppose I shant excise thee of mine company just yet.'],
						'script':['Ignas','Heir','Ignas','Heir','Ignas']})
		if checkAlive('Katre'):
			cutsceneManager.addAction('dialog',
						{'text':['Tis times as these that make me feel most in line with the Beast. The idlers be punished, let us forge a path into this dark!'],
						'script':['Katre']})
		if checkAlive('Eimantas'):
			cutsceneManager.addAction('dialog',
						{'text':['Sage of the Well, what of thee?', 'Whence the lamb doth descend, they art a lion made. So I have spoken, so it shall be.','Thou flatter me Sage, I would have thy advice.','I give no advice young Heir. Rather I only speak what I have seen.'],
						'script':['Heir','Eimantas','Heir','Eimantas']})
		if checkAlive('Benas'):
			cutsceneManager.addAction('dialog',
						{'text':['My liege, what is thy decision?'],
						'script':['Benas']})
		if get_parent().playerUnits.size() == 1:
			cutsceneManager.addAction('dialog',
							{'text':['So be it. I alone shall retrieve this key. No shadow may quell me. Begone fear!'],
							'script':['Heir']})
		else:
			cutsceneManager.addAction('dialog',
						{'text':["Let us descend and find our own path, at worst we may spit upon Sernas' corpse as we take the keys. At best, a new route shall open to us.", 'I am well glad to have thee by my side.'],
						'script':['Heir','Heir']})
			if checkAlive('Benas'):
				cutsceneManager.addAction('dialog',
						{'text':["Old though I may be, I am ever behind thee my Liege, until the day of mine dying breath."],
						'script':['Benas']})
			if checkAlive('Eimantas'):
				cutsceneManager.addAction('dialog',
						{'text':['Rest assured, this is a minor tribulation that we shalt see through, and far more beyond it.'],
						'script':['Eimantas']})
			if checkAlive('Daiga'):
				cutsceneManager.addAction('dialog',
						{'text':["I've no fear of the dark, let's be off while the momentum is upon us!"],
						'script':['Daiga']})
			if checkAlive('Jalena'):
				if checkAlive('Vrikolaz'):
					cutsceneManager.addAction('dialog',
							{'text':["Come on daddy, it won't be all that long til it's mom's raspberry pie every night!", "Ade-Adele. . . P-Pie. . !", "Ohmygosh! You remember mom's name?!!"],
							'script':['Jalena','Vrikolaz','Jalena']})
				else:
					cutsceneManager.addAction('dialog',
						{'text':["I hate to leave my dad like this. . . But. . . But we'll be back for him right?", "Of course Jalena, we'll put him to rest in the castle garden, 'midst the fruiting bushes.", "*sniff. . . He'd really love that. . ."],
						'script':['Jalena','Heir','Jalena']})
			if !checkAlive('Jalena') and checkAlive('Vrikolaz'):
				cutsceneManager.addAction('dialog',
						{'text':['Oooowuuuaaaaaghhhhhhhhh!'],
						'script':['Vrikolaz']})
			if checkAlive('Ignas'):
				cutsceneManager.addAction('dialog',
						{'text':['Come then, let us be off before I miss my little paradise. . .'],
						'script':['Ignas']})
			if checkAlive('Ralfs'):
				cutsceneManager.addAction('dialog',
						{'text':["At first I was worried it'd be the same. That you lot would use me like 'em all. . . But this time I feel like I found some proper friends."],
						'script':['Ralfs']})
			if checkAlive('Katre'):
				cutsceneManager.addAction('dialog',
						{'text':['Blessed are we whom strike at the heart of opportunity and sup upon its juices.'],
						'script':['Katre']})
			if checkAlive('Oskars'):
				cutsceneManager.addAction('dialog',
						{'text':['Thee open my mind with every step, my liege. This meagre one shalt follow thee anywhere, even into such an abyss. . .'],
						'script':['Oskars']})
			if checkAlive('Akvile'):
				cutsceneManager.addAction('dialog',
						{'text':['Thy father may have been the author of my tragedy, but I have forgiven them. I cannot however forgive their killer, whatever it takes to cut down that treasonous toad Zydrunas!'],
						'script':['Akvile']})
			if checkAlive('Ilya'):
				cutsceneManager.addAction('dialog',{'text':['Ilya is ready, yes-yes. Ilya to go home.'],'script':['Ilya']})
				
			cutsceneManager.addAction('dialog',
						{'text':['Let us be off everyone!'],
						'script':['Heir']})
		cutsceneManager.addAction('modulate',{'node':get_parent().get_node('fadeScreen').get_node('Panel'),'color':Color(0,0,0,1),'duration':5})
		cutsceneManager.addAction('changeScene',{'path':"res://scenes/endScreen.tscn"})
		#cutsceneManager.addAction('dialog',
								#{'text':[],
								#'script':[]})
