Config = {}

Config.requiredCops = 2
Config.npcFightOnReject = true
Config.account = 'black_money' -- 'black_money' for crypto, 'money' for cash
Config.drugs = {
    ['weed_pooch'] = 1500,
    ['opium_pooch'] = 3100,
    ['coke_pooch'] = 3700,
    ['meth_pooch'] = 3400,
}
Config.cityPoint = vector3(0.0, -500.0, 100.0) -- set to false to disable distance check

Config.notify = {
    title = 'Drugs',
    nodrugs = 'You don\'t have any drugs to sell',
    cooldown = 'Please wait some time',
    toofar = 'You\'re too far from the city',
    cops = 'There\'s no cops in the city',
    searching = 'You\'re searching for clients for ',
    abort = 'Client has resigned from the order',
    notfound = 'There\'s no nearby clients',
    approach = 'Your client is approaching',
    found = 'You\'ve found client on ',
    press = 'Press [E] to sell',
    reject = 'This stuff is shitty!',
    vehicle = 'You\'ve to leave vehicle to sell',
    sold = 'You\'ve sold x%s of %s for %s$',
    client = 'Your client wants to buy x%s %s',
    police_notify_title = 'Police dispatch',
    police_notify_subtitle = 'Drug sale report',
}

Config.pedlist = {
    'ig_abigail', 'csb_abigail', 'u_m_y_abner', 'a_m_m_afriamer_01', 'ig_mp_agent14',
    'csb_mp_agent14', 'csb_agent', 's_f_y_airhostess_01', 's_m_y_airworker', 'u_m_m_aldinapoli',
    'ig_amandatownley', 'cs_amandatownley', 's_m_y_ammucity_01', 's_m_m_ammucountry',
    'ig_andreas', 'cs_andreas', 'csb_anita', 'u_m_y_antonb', 'csb_anton',
    'g_m_m_armboss_01', 'g_m_m_armgoon_01', 'g_m_y_armgoon_02', 'g_m_m_armlieut_01',
    'mp_s_m_armoured_01', 's_m_m_armoured_01', 's_m_m_armoured_02', 's_m_y_armymech_01',
    'ig_ashley', 'cs_ashley', 's_m_y_autopsy_01', 's_m_m_autoshop_01', 's_m_m_autoshop_02',
    'ig_money', 'csb_money', 'g_m_y_azteca_01', 'u_m_y_babyd', 'g_m_y_ballaeast_01',
    'g_m_y_ballaorig_01', 'g_f_y_ballas_01', 'ig_ballasog', 'csb_ballasog',
    'g_m_y_ballasout_01', 'u_m_m_bankman', 'ig_bankman', 'cs_bankman', 's_m_y_barman_01'
}
