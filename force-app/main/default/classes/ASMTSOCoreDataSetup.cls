public without sharing class ASMTSOCoreDataSetup  
{
    private static String GAMAdServerId;
    private static String BMSAdServerId;
    //private static Map<String,List<AdCreativeSizeType>> sizeTypeMap;
    private static String digitalBannerProductId;
    private static String digitalVideoProductId;
    private static String digitalPreRollProductId;
    private static String digitalMidRollProductId;
    private static String digitalPostRollProductId;
    private static String digitalObjClassId;
    private static String linearObjClassId;
    private List<SObject> objList = new List<SObject>();
    private static Map<String,String> adSpaceRectypeMap;
    private static Map<String,String> DigitalProductPriceMap;

    static
    {
        adSpaceRectypeMap = new Map<String,String>();
        List<RecordType> rectypeList = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'AdCreativeSizeType'];
        for(RecordType rec : rectypeList)
        {
            adSpaceRectypeMap.put(rec.DeveloperName,rec.Id);
        }
    }

    public Boolean invokeMethod(String methodName, Map<String,Object> input)
    {
        try 
        {
            switch on methodName 
            {
                when 'InsertAdServer'
                {
                    insertAdServer(input);
                }
                when 'InsertAdServerMappingRecords'
                {
                    insertAdServerMappingRecords(input);
                }
                when 'CheckAndInsertAdCreativeSizeType'
                {
                    checkAndInsertAdCreativeSizeType();
                }
                when 'InsertDigitalAdSpaceSpecs'
                {
                    //insertDigitalAdSpaceSpecs(input);
                    //insertDigitalAdSpaceSpecs();
                }
                when 'InsertLinearMediaContents'
                {
                    insertLinearMediaContents(input);
                }
                when 'InsertDigitalMediaProperty'
                {
                    insertDigitalMediaProperty();
                }
                when 'InsertLinearAdSpaceSpecs'
                {
                    insertLinearAdSpaceSpecs(input);
                }
                when 'SetupAll'
                {
                    setupAll(input);
                }
                when 'SetupDigital'
                {
                    setupDigital(input);
                }
                when 'SetupLinear'
                {
                    setupLinear(input);
                }
                when 'CheckAndInsertASMMapper'                
				{                    
				    checkAndInsertASMMapper(input);                
				}
                when else 
                {
                    System.debug(LoggingLevel.ERROR,'Invalid methodname');
                    return false;
                }
            }
            return true;

        } 
        catch (Exception e) 
        {
            System.debug(LoggingLevel.ERROR,'invokeMethod -> exception: '+e);
            System.debug(LoggingLevel.ERROR,'Error line number : '+ e.getLinenumber());
            System.debug(LoggingLevel.ERROR,'Error Message Occured : '+e.getStackTraceString());
            return false;
        }
    }

    /*
     * DigitalBannerProductId, DigitalVideoProductId and LinearObjectClassId can be passed in the input.
     */
    private void setupAll(Map<String, Object> input)
    {
        //Digital Data setup
         String digitalProduct = (input.get('digitalProducts')).toString().replace('(','').replace(')','');
        List<String> productArr = digitalProduct.split(',');
        
        insertAdServer(input);
        insertAdServerMappingRecords(input);
        insertDigitalMediaProperty();
        insertAdSizeTypes();
        createDigitalProduct(productArr);
        
        // Linear Data setup
        //insertLinearMediaContents(input);
        //insertLinearAdSpaceSpecs(input);
    }

    /*
     * DigitalBannerProductId, DigitalVideoProductId can be passed in the input.
     */
    private void setupDigital(Map<String, Object> input)
    {
        String digitalProduct = (input.get('digitalProducts')).toString().replace('(','').replace(')','');
        List<String> productArr = digitalProduct.split(',');
        
        Integer digitalServer = [Select COUNT() from AdServer where name='GAM Server'];
        if(digitalServer == 0){
            if(!input.containsKey('GAMAdServerId'))
          {
            input.put('Type','DIGITAL');
            insertAdServer(input);
          }
          insertAdServerMappingRecords(input);
        }
        insertDigitalMediaProperty();
        insertAdSizeTypes();
        createDigitalProduct(productArr);
    }

    /*
     * LinearObjectClassId can be passed in the input.
     */
    private void setupLinear(Map<String, Object> input)
    {
        checkAndInsertASMMapper(input);
        if(!input.containsKey('BMSAdServerId'))
        {
            input.put('Type','LINEAR');
            insertAdServer(input);
        }
        insertLinearMediaContents(input);
        insertLinearAdSpaceSpecs(input);
    }

    
    /*
     * Inserts AdServer records and sets the value of GAMAdServerId and BMSAdServerId
     */
    private void insertAdServer(Map<String,Object> input)
    {
        String adServerType = input.containsKey('Type') ? (String) input.get('Type') : null;
        AdServer gamServer = new AdServer();
        AdServer bmsServer = new AdServer();
        
        if(adServerType != 'LINEAR')
        {
            gamServer.Name = 'GAM Server';
            gamServer.AdServerApplicationName = 'GAM_Sandbox';
            gamServer.AdServerNetworkIdentifier = '22214043670';
            gamServer.NamedCredentialReference = 'GAM_22214043670';
            gamServer.AllowedAdPriorityTypes = 'STANDARD;SPONSORSHIP';
                                                
            objList.add(gamServer);
        }
        
        if(adServerType != 'DIGITAL')
        {
            bmsServer.Name = 'BMS Server';
            bmsServer.AdServerApplicationName = 'BMS_Sandbox';
            bmsServer.AdServerNetworkIdentifier = 'BMS-SNY-01';
            bmsServer.NamedCredentialReference = 'BMS_22214043670';
            bmsServer.AllowedAdPriorityTypes = 'STANDARD;SPONSORSHIP';
                                                 
            objList.add(bmsServer);
        }
        
        if(!objList.isEmpty())
        {
            insert objList;
            objList.clear();
            System.debug(LoggingLevel.DEBUG,' *** 1 : AdServer inserted');
        }
        
        GAMAdServerId = (gamServer.Id != null ? gamServer.Id : GAMAdServerId);
        BMSAdServerId = (bmsServer.Id != null ? bmsServer.Id : BMSAdServerId);
    }

    /*
     * Creates Advertiser Account, Inserts Account Ad Server and User Ad Server mapping records.
     * Calls the VPL_CreateUpdateAdOps and VPL_CreateUpdateAdvertiser  Integration procedures to populate AdServer Identifier values.
     * 
     */ 
    private void insertAdServerMappingRecords(Map<String, Object> input)
    {
        if(String.isBlank(GAMAdServerId))
        {
            GAMAdServerId = (String) input.get('GAMAdServerId');
            system.debug(loggingLevel.DEBUG, '### GAMAdServerId read from user input');
        }

        Id Type = [SELECT Id FROM RecordType WHERE DeveloperName = 'Advertiser'].Id;
        Account acc = new Account (
            Name  = 'New Acc ' +UserInfo.getUserName(),
            Type = Type,
            vlocity_cmt__Active__c = 'Yes',
            vlocity_cmt__Status__c = 'Active'
        );

        insert acc;

        AdServerUser userAdServer = new AdServerUser (
            Name = 'GAM_' + UserInfo.getUserName(),
            UserId = UserInfo.getUserId(),
            AdServerId = GAMAdServerId
        );

        insert userAdServer;
        //Call the Integration procedure to make GAM callout
        adServerMappingFutureCallout(userAdServer.Id,'VPL_CreateUpdateAdOps');
        System.debug(LoggingLevel.DEBUG, ' *** 2 : User AdServer record created and Future job callout made');

        AdServerAccount accAdServer = new AdServerAccount (
            AdvertiserId = acc.Id,
            AdServerId = GAMAdServerId,
            Name = 'GAM_' + acc.Name
        );

        insert accAdServer;
        //Call the Integration procedure to make GAM callout
        adServerMappingFutureCallout(accAdServer.Id,'VPL_CreateUpdateAdvertiser');
        System.debug(LoggingLevel.DEBUG, ' *** 3 : Account AdServer record created and Future job callout made');
    }

    @future
    public static void adServerMappingFutureCallout(Id mappingRecordId, String ipName)
    {
        Map<String, Object> ipInput = new Map<String, Object>();
        Map<String, Object> ipOutput = new Map<String, Object>();
        
        ipInput.put('AdServerMappingId',mappingRecordId);

        ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(ipName, ipInput, new Map<String,Object>());
        System.debug(LoggingLevel.DEBUG, ' **** Mapping Record : ' +mappingRecordId +' ipName : ' +ipName +' Result :' +JSON.serialize(ipOutput));
    }

    /*
     * Checks for existing Ad Creative SizeType records and sets sizeTypeMap static variable. Else creates the Ad Creative Sizetypes and sets sizeTypeMap.
     */ 
    private static Map<String,List<AdCreativeSizeType>> checkAndInsertAdCreativeSizeType()
    {
        List<AdCreativeSizeType> sizeTypeList = [SELECT Id,Name FROM AdCreativeSizeType];
        Map<String,List<AdCreativeSizeType>> sizeTypeMap = new Map<String,List<AdCreativeSizeType>>{'Leaderboard'=> new List<AdCreativeSizeType>(), 'Skyscraper' => new List<AdCreativeSizeType>(), 'Pre-Roll' => new List<AdCreativeSizeType>(), 'Mid-Roll' => new List<AdCreativeSizeType>(), 'Post-Roll' => new List<AdCreativeSizeType>()};
        List<AdCreativeSizeType> tmpList;
        
        System.debug(LoggingLevel.DEBUG, ' ****'+sizeTypeList );
        for(AdCreativeSizeType sizeType : sizeTypeList)
        {
            if(sizeType.Name.containsIgnoreCase('Leaderboard'))
            {
                tmpList = sizeTypeMap.get('Leaderboard');
                tmpList.add(sizeType);
                sizeTypeMap.put('Leaderboard',tmpList);
            }
            else if(sizeType.Name.containsIgnoreCase('Skyscraper'))
            {
                tmpList = sizeTypeMap.get('Skyscraper');
                tmpList.add(sizeType);
                sizeTypeMap.put('Skyscraper',tmpList);
            }
            else if(sizeType.Name.containsIgnoreCase('Pre-Roll'))
            {
                tmpList = sizeTypeMap.get('Pre-Roll');
                tmpList.add(sizeType);
                sizeTypeMap.put('Pre-Roll',tmpList);
            }
            else if(sizeType.Name.containsIgnoreCase('Mid-Roll'))
            {
                tmpList = sizeTypeMap.get('Mid-Roll');
                tmpList.add(sizeType);
                sizeTypeMap.put('Mid-Roll',tmpList);
            }
            else if(sizeType.Name.containsIgnoreCase('Post-Roll'))
            {
                tmpList = sizeTypeMap.get('Post-Roll');
                tmpList.add(sizeType);
                sizeTypeMap.put('Post-Roll',tmpList);
            }
        }
            return sizeTypeMap;
    }

    private static void insertAdSizeTypes()
    {
        Map<String,List<AdCreativeSizeType>> sizeTypeMap = new Map<String,List<AdCreativeSizeType>>{'Leaderboard'=> new List<AdCreativeSizeType>(), 'Skyscraper' => new List<AdCreativeSizeType>(), 'Pre-Roll' => new List<AdCreativeSizeType>(), 'Mid-Roll' => new List<AdCreativeSizeType>(), 'Post-Roll' => new List<AdCreativeSizeType>()};
        List<SObject> objList = new List<SObject>();
      if(sizeTypeMap.get('Leaderboard').isEmpty())
        {
            AdCreativeSizeType desktopLeaderboard = new AdCreativeSizeType (
                Name = 'Leaderboard Desktop',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 970.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(desktopLeaderboard);

            AdCreativeSizeType mobileLeaderboard = new AdCreativeSizeType (
                Name = 'Leaderboard Mobile',
                MediaType = 'Digital Banner',
                Height = 50.0,
                Width = 320.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(mobileLeaderboard);

            AdCreativeSizeType standardLeaderboard = new AdCreativeSizeType (
                Name = 'Leaderboard Standard',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 728.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(standardLeaderboard);
        }
      if(sizeTypeMap.get('Skyscraper').isEmpty())
        {
            AdCreativeSizeType standardSkyscraper = new AdCreativeSizeType (
                Name = 'Skyscraper Standard',
                MediaType = 'Digital Banner',
                Height = 600.0,
                Width = 120.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(standardSkyscraper);

            AdCreativeSizeType wideSkyscraper = new AdCreativeSizeType (
                Name = 'Skyscraper Wide',
                MediaType = 'Digital Banner',
                Height = 600.0,
                Width = 160.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(wideSkyscraper);
        }  
      if(sizeTypeMap.get('Pre-Roll').isEmpty())
        {
            AdCreativeSizeType desktopLeaderboard = new AdCreativeSizeType (
                Name = 'Pre-Roll Desktop',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 970.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(desktopLeaderboard);

            AdCreativeSizeType mobileLeaderboard = new AdCreativeSizeType (
                Name = 'Pre-Roll Mobile',
                MediaType = 'Digital Banner',
                Height = 50.0,
                Width = 320.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(mobileLeaderboard);

            AdCreativeSizeType standardLeaderboard = new AdCreativeSizeType (
                Name = 'Pre-Roll Standard',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 728.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(standardLeaderboard);
        }  
       if(sizeTypeMap.get('Mid-Roll').isEmpty())
        {
            AdCreativeSizeType desktopLeaderboard = new AdCreativeSizeType (
                Name = 'Mid-Roll Desktop',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 970.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(desktopLeaderboard);

            AdCreativeSizeType mobileLeaderboard = new AdCreativeSizeType (
                Name = 'Mid-Roll Mobile',
                MediaType = 'Digital Banner',
                Height = 50.0,
                Width = 320.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(mobileLeaderboard);

            AdCreativeSizeType standardLeaderboard = new AdCreativeSizeType (
                Name = 'Mid-Roll Standard',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 728.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(standardLeaderboard);
        }

        if(sizeTypeMap.get('Post-Roll').isEmpty())
        {
            AdCreativeSizeType desktopLeaderboard = new AdCreativeSizeType (
                Name = 'Post-Roll Desktop',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 970.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(desktopLeaderboard);

            AdCreativeSizeType mobileLeaderboard = new AdCreativeSizeType (
                Name = 'Post-Roll Mobile',
                MediaType = 'Digital Banner',
                Height = 50.0,
                Width = 320.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(mobileLeaderboard);

            AdCreativeSizeType standardLeaderboard = new AdCreativeSizeType (
                Name = 'Post-Roll Standard',
                MediaType = 'Digital Banner',
                Height = 90.0,
                Width = 728.0,
                UnitOfMeasure = 'pixels'
            );
            objList.add(standardLeaderboard);
        }
       
        insert objList;
        objList.clear();
    }

    /*
     * If DEL_OLD_MED_PROP is sent as False, then existing Digital Media Property records won't be deleted.
     * DigitalBannerProductId and DigitalVideoProductId can be passed in the input.
     * GAMAdServerId would be read from the input if it was not already set.
     */ 
    private static void insertDigitalMediaProperty(){
        List<SObject> objList = new List<SObject>();
        
        Integer HomeDigitalMPropFlag = [SELECT COUNT() FROM MediaChannel where name='TN Home Page'];
        Integer ScienceDigitalMPropFlag = [SELECT COUNT() FROM MediaChannel where name='TN Science Page'];
        Integer SportsDigitalMPropFlag = [SELECT COUNT() FROM MediaChannel where name='TN Sports Page'];
        Integer BloombergDigitalMPropFlag = [SELECT COUNT() FROM MediaChannel where name='berg.com'];
        
       /*Boolean deleteExistingDigitalMP = true;
        
        if(deleteExistingDigitalMP)
        {
            objList = [SELECT ID FROM MediaChannel WHERE MediaType = 'Digital'];
            if(!objList.isEmpty())
            {
                delete objList;
                objList.clear();
            }
        } */
        if(HomeDigitalMPropFlag == 0){
            MediaChannel HomeDigitalMProp = new MediaChannel(
            Name = 'TN Home Page',
            MediaType = 'Digital',
            AvailableLanguages = 'English;Spanish',
            PricingCategory = 'Standard'
        );
        objList.add(HomeDigitalMProp);
        }
        if(ScienceDigitalMPropFlag == 0){
            MediaChannel ScienceDigitalMProp = new MediaChannel(
            Name = 'TN Science Page',
            MediaType = 'Digital',
            AvailableLanguages = 'English;Spanish',
            PricingCategory = 'Standard'
        );
        objList.add(ScienceDigitalMProp);
        }
        if(SportsDigitalMPropFlag == 0){
            MediaChannel SportsDigitalMProp = new MediaChannel(
            Name = 'TN Sports Page',
            MediaType = 'Digital',
            AvailableLanguages = 'English',
            PricingCategory = 'Premium'
          );
          objList.add(SportsDigitalMProp);
        }
         
        if(BloombergDigitalMPropFlag == 0){
            MediaChannel BloombergDigitalMProp = new MediaChannel(
            Name = 'berg.com',
            MediaType = 'Digital',
            AvailableLanguages = 'English',
            PricingCategory = 'Premium'
          );
          objList.add(BloombergDigitalMProp);
        }
         
        if(objList.size() > 0){
            insert objList;
        	objList.clear();
			System.debug(LoggingLevel.DEBUG,' *** 4 : Media Property records inserted');
        }        
         
    }
    
    private static void insertDigitalVideoAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
            
        if(String.isBlank(productCode)) return;
		MediaChannel HomeDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Home Page'];
        MediaChannel ScienceDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Science Page'];
        MediaChannel SportsDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Sports Page'];
        
        AdSpaceSpecification HVLdr = new AdSpaceSpecification(
            Name = 'Leaderboard TN_Home_Video',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367657743',
            Product2Id = productCode,
            AdSpaceType = 'Leaderboard',
            MediaChannelId = HomeDigitalMProp.Id
        );
        objList.add(HVLdr);

        AdSpaceSpecification HVSky = new AdSpaceSpecification(
            Name = 'Skyscraper TN_Home_Video',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367660293',
            Product2Id = productCode,
            AdSpaceType = 'Skyscraper',
            MediaChannelId = HomeDigitalMProp.Id
        );
        objList.add(HVSky);

        AdSpaceSpecification SVLdr = new AdSpaceSpecification(
            Name = 'Leaderboard TN_Science_Video',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367661406',
            Product2Id = productCode,
            AdSpaceType = 'Leaderboard',
            MediaChannelId = ScienceDigitalMProp.Id
        );
        objList.add(SVLdr);

        AdSpaceSpecification SVSky = new AdSpaceSpecification(
            Name = 'Skyscraper TN_Science_Video',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367662420',
            Product2Id = productCode,
            AdSpaceType = 'Skyscraper',
            MediaChannelId = ScienceDigitalMProp.Id
        );
        objList.add(SVSky);

        AdSpaceSpecification SpVLdr = new AdSpaceSpecification(
            Name = 'Leaderboard TN_Sports_Video',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367559510',
            Product2Id = productCode,
            AdSpaceType = 'Leaderboard',
            MediaChannelId = SportsDigitalMProp.Id
        );
        objList.add(SpVLdr);

        AdSpaceSpecification SpVSky = new AdSpaceSpecification(
            Name = 'Skyscraper TN_Sports_Video',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367560629',
            Product2Id = productCode,
            AdSpaceType = 'Skyscraper',
            MediaChannelId = SportsDigitalMProp.Id
        );
        objList.add(SpVSky);        
        
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 15 Digital AdSpace records inserted');

        createAdSpaceGroupAndMember(objList);
        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
     private static void insertDigitalBannerAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
       List<SObject> objList = new List<SObject>();
       
        if(String.isBlank(productCode)) return;
        
		MediaChannel HomeDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Home Page'];
        MediaChannel ScienceDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Science Page'];
        MediaChannel SportsDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Sports Page'];
        
        AdSpaceSpecification HBLdr = new AdSpaceSpecification(
            Name = 'Leaderboard TN_Home_Banner',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367657743',
            Product2Id = productCode,
            AdSpaceType = 'Leaderboard',
            MediaChannelId = HomeDigitalMProp.Id
        );
        objList.add(HBLdr);

        AdSpaceSpecification HBSky = new AdSpaceSpecification(
            Name = 'Skyscraper TN_Home_Banner',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367660293',
            Product2Id = productCode,
            AdSpaceType = 'Skyscraper',
            MediaChannelId = HomeDigitalMProp.Id
        );
        objList.add(HBSky);

        AdSpaceSpecification SBLdr = new AdSpaceSpecification(
            Name = 'Leaderboard TN_Science_Banner',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367661406',
            Product2Id = productCode,
            AdSpaceType = 'Leaderboard',
            MediaChannelId = ScienceDigitalMProp.Id
        );
        objList.add(SBLdr);
        
        AdSpaceSpecification SBSky = new AdSpaceSpecification(
            Name = 'Skyscraper TN_Science_Banner',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367662420',
            Product2Id = productCode,
            AdSpaceType = 'Skyscraper',
            MediaChannelId = ScienceDigitalMProp.Id
        );
        objList.add(SBSky);
        
        AdSpaceSpecification SpBLdr = new AdSpaceSpecification(
            Name = 'Leaderboard TN_Sports_Banner',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367559510',
            Product2Id = productCode,
            AdSpaceType = 'Leaderboard',
            MediaChannelId = SportsDigitalMProp.Id
        );
        objList.add(SpBLdr);


        AdSpaceSpecification SpBSky = new AdSpaceSpecification(
            Name = 'Skyscraper TN_Sports_Banner',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367560629',
            Product2Id = productCode,
            AdSpaceType = 'Skyscraper',
            MediaChannelId = SportsDigitalMProp.Id
        );
        objList.add(SpBSky);
        
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 15 Digital AdSpace records inserted');

        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
          private static void insertDigital30PreAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;

        MediaChannel SportsDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Sports Page'];
        AdSpaceSpecification nsPre30 = new AdSpaceSpecification(
            Name = '30 sec non-skippable-pre',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367560629',
            Product2Id = productCode,
            AdSpaceType = 'Pre-Roll',
            MediaChannelId = SportsDigitalMProp.Id
        );
        objList.add(nsPre30);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 30 sec pre Digital AdSpace records inserted');
        
        associateAdSpecToSizeType(objList,sizeTypeMap);
        objList.clear();
    }
     private static void insertDigital20PreAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;

        MediaChannel SportsDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Sports Page'];
        
        AdSpaceSpecification nsPre20 = new AdSpaceSpecification(
            Name = '20 sec non-skippable-pre',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367560629',
            Product2Id = productCode,
            AdSpaceType = 'Pre-Roll',
            MediaChannelId = SportsDigitalMProp.Id
        );
        objList.add(nsPre20);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 20sec pre Digital AdSpace records inserted');
        
        associateAdSpecToSizeType(objList,sizeTypeMap);
        objList.clear();
    }
     private static void insertDigital10PreAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;

        MediaChannel SportsDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Sports Page'];
        
        AdSpaceSpecification nsPre10 = new AdSpaceSpecification(
            Name = '10 sec non-skippable-pre',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367560629',
            Product2Id = productCode,
            AdSpaceType = 'Pre-Roll',
            MediaChannelId = SportsDigitalMProp.Id
        );
        objList.add(nsPre10);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 10sec pre Digital AdSpace records inserted');
        
        associateAdSpecToSizeType(objList,sizeTypeMap);
        objList.clear();
    }
     private static void insertDigital30MidAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;
        
        MediaChannel ScienceDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Science Page'];
        
        AdSpaceSpecification skMid30 = new AdSpaceSpecification(
            Name = '30 sec non-skippable-mid',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367662420',
            Product2Id = productCode,
            AdSpaceType = 'Mid-Roll',
            MediaChannelId = ScienceDigitalMProp.Id
        );
        objList.add(skMid30);
         
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 30secmid Digital AdSpace records inserted');

        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
     private static void insertDigital20MidAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;
        
        MediaChannel ScienceDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Science Page'];
        
        AdSpaceSpecification skMid20 = new AdSpaceSpecification(
            Name = '20 sec non-skippable-mid',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367662420',
            Product2Id = productCode,
            AdSpaceType = 'Mid-Roll',
            MediaChannelId = ScienceDigitalMProp.Id
        );
        objList.add(skMid20);
         
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 20sec Mid Digital AdSpace records inserted');

        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
     private static void insertDigital10MidAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;
        
        MediaChannel ScienceDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Science Page'];
        
        AdSpaceSpecification skMid10 = new AdSpaceSpecification(
            Name = '10 sec non-skippable-mid',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367662420',
            Product2Id = productCode,
            AdSpaceType = 'Mid-Roll',
            MediaChannelId = ScienceDigitalMProp.Id
        );
        objList.add(skMid10);
         
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 10sec mid Digital AdSpace records inserted');

        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
 	private static void insertDigital30PostAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;
        
		MediaChannel HomeDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Home Page'];
        
        AdSpaceSpecification nsPost30 = new AdSpaceSpecification(
            Name = '30 sec non-skippable-post',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367660293',
            Product2Id = productCode,
            AdSpaceType = 'Post-Roll',
            MediaChannelId = HomeDigitalMProp.Id
        );
        objList.add(nsPost30);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 30sec post Digital AdSpace records inserted');

        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
    private static void insertDigital20PostAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;
        
		MediaChannel HomeDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Home Page'];
        
        AdSpaceSpecification nsPost20 = new AdSpaceSpecification(
            Name = '20 sec non-skippable-post',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367660293',
            Product2Id = productCode,
            AdSpaceType = 'Post-Roll',
            MediaChannelId = HomeDigitalMProp.Id
        );
        objList.add(nsPost20);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 15 Digital AdSpace records inserted');

        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
    private static void insertDigital10PostAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        
        if(String.isBlank(productCode)) return;
        
		MediaChannel HomeDigitalMProp = [SELECT ID,name FROM MediaChannel where name='TN Home Page'];
        
        AdSpaceSpecification nsPost10 = new AdSpaceSpecification(
            Name = '10 sec non-skippable-post',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367660293',
            Product2Id = productCode,
            AdSpaceType = 'Post-Roll',
            MediaChannelId = HomeDigitalMProp.Id
        );
        objList.add(nsPost10);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 10sec Post Digital AdSpace records inserted');

        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
    private static void insertDigitalBloombergAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        if(String.isBlank(productCode)) return;
        
        MediaChannel BloombergDigitalMProp = [SELECT ID,name FROM MediaChannel where name='berg.com'];
        
        objList = new List<SObject>();
        AdSpaceSpecification Bloomberg = new AdSpaceSpecification(
            Name = 'Digital Banner-berg.com',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367657743',
            Product2Id = productCode,
            AdSpaceType = 'Skyscraper',
            MediaChannelId = BloombergDigitalMProp.Id
        );
        objList.add(Bloomberg);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 15 Digital AdSpace records inserted');
        associateAdSpecToSizeType(objList,sizeTypeMap);

        objList.clear();
    }
     
     private static void insertDigitalBloombergCPMAdSpaceSpecs(String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId)
    {
        List<SObject> objList = new List<SObject>();
        if(String.isBlank(productCode)) return;

        
        MediaChannel BloombergDigitalMProp = [SELECT ID,name FROM MediaChannel where name='berg.com'];

        System.debug(LoggingLevel.DEBUG,' *** 4 : Media Property records inserted');

        objList = new List<SObject>();
        AdSpaceSpecification Bloomberg = new AdSpaceSpecification(
            Name = 'Digital Banner-berg.com-CPM',
            Type = 'Ad Space',
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '22367657743',
            Product2Id = productCode,
            AdSpaceType = 'Leaderboard',
            MediaChannelId = BloombergDigitalMProp.Id
        );
        objList.add(Bloomberg);
        insert objList;
        System.debug(LoggingLevel.DEBUG, '*** 15 Digital AdSpace records inserted');
        associateAdSpecToSizeType(objList,sizeTypeMap);
        objList.clear();
    }

    private static void createAdSpaceGroupAndMember(List<SObject> objList)
    {
        List<AdSpaceSpecification> adSpecList = (List<AdSpaceSpecification>) objList;
        List<AdSpaceGroupMember> adSpecMemberList = new List<AdSpaceGroupMember>();

        AdSpaceSpecification LBGroup = new AdSpaceSpecification(
            Name = 'Leaderboard Banner AdGroup',
            Type = adSpaceRectypeMap.get('AdSpaceGroup'),
            IsActive = true,
            AdServerId = GAMAdServerId,
            AdServerAdSpaceIdentifier = '30218805',
            Product2Id = digitalVideoProductId,
            AdSpaceType = 'Leaderboard'
        );
        insert LBGroup;

        for(AdSpaceSpecification adSpec : adSpecList)
        {
            if(adSpec.AdSpaceType.equalsIgnoreCase('Leaderboard'))
            {
                AdSpaceGroupMember newRec = new AdSpaceGroupMember(
                    Name = adSpec.Name,
                    AdSpaceGroupId = LBGroup.Id,
                    AdSpaceGroupMemberNameId = adSpec.Id
                );
                adSpecMemberList.add(newRec);
            }
        }

        if(!adSpecMemberList.isEmpty())
        {
            insert adSpecMemberList;
            system.debug(LoggingLevel.DEBUG, '*** 6 Digital AdSpace Group Association done');
        }
    }

    private static void associateAdSpecToSizeType(List<SObject> objList,Map<String,List<AdCreativeSizeType>> sizeTypeMap)
    { 
        List<AdSpaceSpecification> adSpecList = (List<AdSpaceSpecification>) objList;
        List<AdSpaceCreativeSizeType> adspaceSizeMappingList = new List<AdSpaceCreativeSizeType>();

        for(AdSpaceSpecification adSpec : adSpecList)
        {
            if(sizeTypeMap.containsKey(adSpec.AdSpaceType))
            {
                for(AdCreativeSizeType sizeType : sizeTypeMap.get(adSpec.AdSpaceType))
                {
                    AdSpaceCreativeSizeType record = new AdSpaceCreativeSizeType(
                        Name = sizeType.Name,
                        AdCreativeSizeTypeId = sizeType.Id,
                        AdSpaceSpecificationId = adSpec.Id
                    );
                    adspaceSizeMappingList.add(record);
                }
            }
        }

        if(!adspaceSizeMappingList.isEmpty())
        {
            insert adspaceSizeMappingList;
            system.debug(LoggingLevel.DEBUG, '*** 7 Digital AdSpace SizeType Association done');
        }
        
    }
    
   
    /* Queuable Jobs for Digital
*/
    public class AsyncCreationOfDigitalProduct implements Queueable {
    	String digitalObjClassId;
		String name;
		String productCode;
        String GAMAdServerId;
        Map<String, Object> inputs = new Map<String, Object>();
        Id priceListId;
        String priceCode = '10$OneTime';
        Map<String,String> pricingElementMap;
        Map<String,List<AdCreativeSizeType>> sizeTypeMap;

		public AsyncCreationOfDigitalProduct(String name, String productCode,Map<String,String> pricingElementMap,Id priceListId,Map<String,List<AdCreativeSizeType>> sizeTypeMap,String GAMAdServerId) {
			this.digitalObjClassId = [SELECT ID FROM vlocity_cmt__ObjectClass__c WHERE NAME = 'Ad Digital Banner and Video' AND vlocity_cmt__ObjectApiName__c = 'Product2' LIMIT 1].Id;
			this.name = name;
			this.productCode = productCode;
            this.priceListId = priceListId;
            this.pricingElementMap = pricingElementMap;
            this.sizeTypeMap = sizeTypeMap;
            this.GAMAdServerId = GAMAdServerId;
		}

		public void execute(QueueableContext context) {
			createProductNAssignPriceList(priceListId, name, productCode,sizeTypeMap);
		}

		private void createProductNAssignPriceList(Id priceListId, String name, String productCode,Map<String,List<AdCreativeSizeType>> sizeTypeMap)
        {
              Map<String,Object> entity = new Map<String,Object>{
                 	'vlocity_cmt__IsOrderable__c' => true,
                 	'vlocity_cmt__IsNotAssetizable__c' => false,
                 	'vlocity_cmt__Status__c' => 'Active',
                 	'IsActive' => true,
                 	'vlocity_cmt__ObjectTypeId__c' => this.digitalObjClassId,
                 	'Name' => this.name,
                 	'ProductCode' => 'AD-DG-'+(this.productCode).touppercase(),
                 	'vlocity_cmt__Type__c' => 'Digital',
                 	'vlocity_cmt__FulfilmentStartDate__c' => ((DateTime)System.today().addDays(-10)).getTime(),
                 	'vlocity_cmt__SellingStartDate__c' => ((DateTime)System.today().addDays(-10)).getTime()
                 	//'vlocity_cmt__AttributeDefaultValues__c' =>'{"ADS-RATE-TYPE":"CPM"}'
                };
                inputs.put('epcRequest',new Map<String,Object>{'entity' => entity});
                Object result = vlocity_cmt.ProductConsoleControllerV2.invokeMethod('createProduct2', JSON.serialize(inputs));
 			    system.debug(LoggingLevel.DEBUG,'***** EPC CreateProduct Response : '+result);
                
                Map<String,Object> jsonResult = (Map<String,Object>)((Map<String,Object>)((List<Object>)((Map<String,Object>)((Map<String,Object>) JSON.deserializeUntyped(String.valueOf(result))).get('epcResponse')).get('entities'))[0]).get('entity');
                system.debug(LoggingLevel.DEBUG,'***** EPC CreateProduct Response : '+jsonResult);
                
                //Publish the Product
                inputs.clear();
                inputs.put('ProductCode',(Id)jsonResult.get('Id'));
                //inputs.put('productId',(Id)jsonResult.get('Id'));

                result = vlocity_cmt.ProductConsoleControllerV2.invokeMethod('publishProduct', JSON.serialize(inputs));
                system.debug(LoggingLevel.DEBUG,'***** EPC PublishProduct Response : ' +result);
            	system.debug(LoggingLevel.DEBUG,'*****productName:' +this.name+'&&&');
            	if(this.name == 'Digital Video'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigitalVideoAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == 'Digital Banner'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigitalBannerAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '30 sec skippable Pre-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital30PreAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '20 sec skippable Pre-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital20PreAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '10 sec skippable Pre-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital10PreAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '30 sec skippable Mid-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital30MidAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '20 sec skippable Mid-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital20MidAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '10 sec skippable Mid-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital10MidAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '30 sec skippable Post-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital30PostAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '20 sec skippable Post-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital20PostAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(this.name == '10 sec skippable Post-roll'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'10$OneTime'));
					insertDigital10PostAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(name == 'Digital Banner-berg.com'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'20$OneTime'));
					insertDigitalBloombergAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}else if(name == 'Digital Banner-berg.com-CPM'){
                    ID priceListJobId = System.enqueueJob(new AsyncCreationOfPricelistEntries((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),'25$OneTime'));
					insertDigitalBloombergCPMAdSpaceSpecs((Id)jsonResult.get('Id'),sizeTypeMap,GAMAdServerId);
            	}
        }
	}
    /* Queuable Jobs for Digital Ends
*/ 
    
    
    
    
    //@future
    private static void createDigitalProduct(List<String> Products)
    {
        try{
            Map<String,List<AdCreativeSizeType>> sizeTypeMap = checkAndInsertAdCreativeSizeType();
            //List<String>DigitalProducts = new List<String>{'Digital Video','Digital Banner','30 sec skippable Pre-roll','30 sec skippable Mid-roll','30 sec skippable Post-roll','Digital Banner-Bloomberg.com','Digital Banner-Bloomberg.com-CPM'};
            List<String>DigitalProducts = Products;
            Id priceListId = [SELECT ID FROM vlocity_cmt__PriceList__c WHERE vlocity_cmt__Code__c = 'ADSALES-PRICELIST'].Id;
            GAMAdServerId = [Select Id from AdServer where name='GAM Server'].Id;
            Map<String,String> pricingElementMap = createOrFetchPricingElements(priceListId);
            for(integer i=0;i<DigitalProducts.size();i++){
                if(DigitalProducts[i] == 'Digital Video' || DigitalProducts[i] == 'Digital Banner' || DigitalProducts[i].contains('Banner-berg.com')){
                	ID jobId = System.enqueueJob(new AsyncCreationOfDigitalProduct(DigitalProducts[i].trim(), (DigitalProducts[i].split(' ')[1]), pricingElementMap,priceListId,sizeTypeMap,GAMAdServerId));
                }else if(DigitalProducts[i].contains('30 sec')|| DigitalProducts[i].contains('20 sec') || DigitalProducts[i].contains('10 sec')){
                    List<String> productCodeArray =  DigitalProducts[i].split('skippable');
                    ID jobId = System.enqueueJob(new AsyncCreationOfDigitalProduct(DigitalProducts[i].trim(), (productCodeArray[0].deleteWhitespace()+'-'+productCodeArray[1].trim()), pricingElementMap,priceListId,sizeTypeMap,GAMAdServerId));
                }
            }
            //checkAndInsertAdCreativeSizeType();
            //insertDigitalAdSpaceSpecs();
        }
        catch (Exception e) 
        {
            System.debug(LoggingLevel.ERROR,'invokeMethod -> exception: '+e);
            System.debug(LoggingLevel.ERROR,'Error line number : '+ e.getLinenumber());
            System.debug(LoggingLevel.ERROR,'Error Message Occured : '+e.getStackTraceString());
        }
        
    }
        
    private void insertLinearMediaContents(Map<String,Object> input)
    {
        Boolean deleteExistingLinearMP = input.containsKey('DEL_OLD_MED_PROP')? (Boolean) input.get('DEL_OLD_MED_PROP') : true;

        if(deleteExistingLinearMP)
        {
            objList = new List<SObject>();
            objList = [SELECT ID FROM MediaChannel WHERE MediaType = 'TV'];
            if(!objList.isEmpty())
            {
                delete objList;
                objList.clear();
            }

            objList = [SELECT ID FROM MediaContentTitle];
            if(!objList.isEmpty())
            {
                delete objList;
                objList.clear();
            }
        }
        objList = new List<SObject>();
        MediaContentTitle sopranos = new MediaContentTitle(
                                Name = 'The Sopranos',
                                Genre = 'Thriller;Soap Opera',
                                Description = 'New Jersey mob boss Tony Soprano deals with personal and professional issues in his home and business life that affect his mental state, leading him to seek professional psychiatric counseling.',
                                AvailableLanguages = 'English',
                                NumberOfEpisodes = 86
                            );
        objList.add(sopranos);

        MediaContentTitle wire = new MediaContentTitle(
                                Name = 'The Wire',
                                Genre = 'Thriller;Soap Opera;Documentary',
                                Description = 'The Baltimore drug scene, as seen through the eyes of drug dealers and law enforcement.',
                                AvailableLanguages = 'English',
                                NumberOfEpisodes = 60
                            );
        objList.add(wire);

        MediaContentTitle sportsTonight = new MediaContentTitle(
                                Name = 'The Sports Tonight',
                                Genre = 'News;Documentary',
                                Description = 'One place for all the Sports and Action across the globe.',
                                AvailableLanguages = 'English'
                            );
        objList.add(sportsTonight);

        MediaContentTitle topChef = new MediaContentTitle(
                                Name = 'The Top Chef',
                                Genre = 'Sitcom',
                                Description = 'The Daily Cooking show.',
                                AvailableLanguages = 'English;Hindi'
                            );
        objList.add(topChef);

        MediaContentTitle cricket01 = new MediaContentTitle(
                                Name = 'India-England Cricket Series',
                                Genre = 'Documentary',
                                Description = '3 Tests, 5 ODIs and 3 T20s.',
                                AvailableLanguages = 'English;Hindi'
                            );
        objList.add(cricket01);

        MediaContentTitle cricket02 = new MediaContentTitle(
                                Name = 'England-Australia Ashes Series',
                                Genre = 'Documentary',
                                Description = '5 Tests held in Australia.',
                                AvailableLanguages = 'English;Hindi'
                            );
        objList.add(cricket02);

        MediaContentTitle musicHunt = new MediaContentTitle(
                                Name = 'The Music Hunt',
                                Genre = 'Comedy;Movie',
                                Description = 'The Great Singing competetion.',
                                AvailableLanguages = 'Hindi',
                                NumberOfEpisodes = 36
                            );
        objList.add(musicHunt);

        insert objList;
        objList.clear();

        system.debug(LoggingLevel.DEBUG, '*** 8 Linear Media Contents created');

        objList = new List<SObject>();
        MediaChannel setHd = new MediaChannel(
                                Name = 'Sony SET HD',
                                MediaType = 'TV',
                                PricingCategory = 'Standard',
                                AvailableLanguages = 'Hindi'
        );
        objList.add(setHd);

        MediaChannel ten1Hd = new MediaChannel(
                                Name = 'Sony TEN1 HD',
                                MediaType = 'TV',
                                PricingCategory = 'Premium',
                                AvailableLanguages = 'English'
        );
        objList.add(ten1Hd);

        MediaChannel ten2Hd = new MediaChannel(
                                Name = 'Sony TEN2 HD',
                                MediaType = 'TV',
                                PricingCategory = 'Standard',
                                AvailableLanguages = 'Hindi;English'
        );
        objList.add(ten2Hd);

        MediaChannel pixHd = new MediaChannel(
                                Name = 'Sony PIX HD',
                                MediaType = 'TV',
                                PricingCategory = 'Premium',
                                AvailableLanguages = 'English'
        );
        objList.add(pixHd);

        insert objList;
        system.debug(LoggingLevel.DEBUG, '*** 9 Linear Media Property records created');
    }
    
    /*
     * LinearObjectClassId can be passed in the input.
     * BMSAdServerId would be read from the input if it was not already set.
     */ 
    private void insertLinearAdSpaceSpecs(Map<String, Object> input)
    {
        if(String.isBlank(BMSAdServerId))
        {
            BMSAdServerId = (String) input.get('BMSAdServerId');
            system.debug(loggingLevel.DEBUG, '### BMSAdServerId read from user input');
        }

        linearObjClassId = (String) input.get('LinearObjectClassId');

        if(String.isBlank(linearObjClassId))
        {
            linearObjClassId = [SELECT ID FROM vlocity_cmt__ObjectClass__c WHERE NAME = 'Ad Linear Television' AND vlocity_cmt__ObjectApiName__c = 'Product2' LIMIT 1].Id;
        }

        if(String.isBlank(linearObjClassId)) return;

        Map<String,String> medPropMap = new Map<String,String>();
        Map<String,String> medContMap = new Map<String,String>();
        Map<String,String> adSpecPriceMap = new Map<String,String>();

        for(MediaChannel mp : [SELECT Id, Name FROM MediaChannel WHERE MediaType = 'TV'])
        {
            medPropMap.put(mp.Name,mp.Id);
        }

        for(MediaContentTitle mc : [SELECT Id, Name FROM MediaContentTitle])
        {
            medContMap.put(mc.Name,mc.Id);
        }

        objList = new List<SObject>();
        AdSpaceSpecification spec1 = new AdSpaceSpecification(
                                Name = 'Sopranos Mon-Fri 2100-2200 Hrs',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SPX-SOPR-MF-2100',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('The Sopranos'),
                                MediaChannelId = medPropMap.get('Sony PIX HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 9.1,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(21,0,0,0),
                                EndTime = Time.newInstance(22,0,0,0),
                                StartWeekDay = 'Monday',
                                EndWeekDay = 'Friday',
                                StartDateTime = System.Today() - 20,
                                EndDateTime = System.Today() + 66
        );

        objList.add(spec1);
        adSpecPriceMap.put(spec1.AdServerAdSpaceIdentifier,'30$OneTime');

        AdSpaceSpecification spec2 = new AdSpaceSpecification(
                                Name = 'Sopranos Mon-Fri 1600-1700 Hrs',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SPX-SOPR-MF-1600',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('The Sopranos'),
                                MediaChannelId = medPropMap.get('Sony PIX HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 8.1,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Repeat',
                                PublisherDayPart = 'Non Prime Time',
                                StartTime = Time.newInstance(16,0,0,0),
                                EndTime = Time.newInstance(17,0,0,0),
                                StartWeekDay = 'Monday',
                                EndWeekDay = 'Friday',
                                StartDateTime = System.Today() - 20,
                                EndDateTime = System.Today() + 66
        );

        objList.add(spec2);
        adSpecPriceMap.put(spec2.AdServerAdSpaceIdentifier,'20$OneTime');

        AdSpaceSpecification spec3 = new AdSpaceSpecification(
                                Name = 'Wire Mon-Fri 2200-2300 Hrs',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SET-WIRE-MF-2200',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('The Wire'),
                                MediaChannelId = medPropMap.get('Sony SET HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 9.4,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(22,0,0,0),
                                EndTime = Time.newInstance(23,0,0,0),
                                StartWeekDay = 'Monday',
                                EndWeekDay = 'Friday',
                                StartDateTime = System.Today() - 10,
                                EndDateTime = System.Today() + 50
        );

        objList.add(spec3);
        adSpecPriceMap.put(spec3.AdServerAdSpaceIdentifier,'30$OneTime');

        AdSpaceSpecification spec4 = new AdSpaceSpecification(
                                Name = 'Wire Mon-Fri 1100-1200 Hrs',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SET-WIRE-MF-1100',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('The Wire'),
                                MediaChannelId = medPropMap.get('Sony SET HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 9.2,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Repeat',
                                PublisherDayPart = 'Non Prime Time',
                                StartTime = Time.newInstance(11,0,0,0),
                                EndTime = Time.newInstance(12,0,0,0),
                                StartWeekDay = 'Monday',
                                EndWeekDay = 'Friday',
                                StartDateTime = System.Today() - 10,
                                EndDateTime = System.Today() + 50
        );

        objList.add(spec4);
        adSpecPriceMap.put(spec4.AdServerAdSpaceIdentifier,'20$OneTime');

        AdSpaceSpecification spec5 = new AdSpaceSpecification(
                                Name = 'SportsTonight Daily 2100-2130 Hrs',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'STEN1-ST-DAILY-2100',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('The Sports Tonight'),
                                MediaChannelId = medPropMap.get('Sony TEN1 HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 8.6,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(21,0,0,0),
                                EndTime = Time.newInstance(21,30,0,0),
                                StartWeekDay = 'Monday',
                                EndWeekDay = 'Monday',
                                StartDateTime = System.Today() - 20,
                                EndDateTime = System.Today() + 210
        );

        objList.add(spec5);
        adSpecPriceMap.put(spec5.AdServerAdSpaceIdentifier,'30$OneTime');

        AdSpaceSpecification spec6 = new AdSpaceSpecification(
                                Name = 'TopChef Daily 1300-1330 Hrs',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SET-TC-DAILY-1300',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('The Top Chef'),
                                MediaChannelId = medPropMap.get('Sony SET HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 8.3,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Non Prime Time',
                                StartTime = Time.newInstance(13,0,0,0),
                                EndTime = Time.newInstance(13,30,0,0),
                                StartWeekDay = 'Monday',
                                EndWeekDay = 'Monday',
                                StartDateTime = System.Today() - 20,
                                EndDateTime = System.Today() + 210
        );

        objList.add(spec6);
        adSpecPriceMap.put(spec6.AdServerAdSpaceIdentifier,'20$OneTime');

        AdSpaceSpecification spec7 = new AdSpaceSpecification(
                                Name = 'MusicHunt Sat-Sun 2000-2130 Hrs',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SET-MH-SS-2000',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('The Music Hunt'),
                                MediaChannelId = medPropMap.get('Sony SET HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 8.7,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(20,0,0,0),
                                EndTime = Time.newInstance(21,30,0,0),
                                StartWeekDay = 'Saturday',
                                EndWeekDay = 'Sunday',
                                StartDateTime = System.Today() - 45,
                                EndDateTime = System.Today() + 81
        );

        objList.add(spec7);
        adSpecPriceMap.put(spec7.AdServerAdSpaceIdentifier,'40$OneTime');

        AdSpaceSpecification spec8 = new AdSpaceSpecification(
                                Name = 'Ind vs Eng 5 match ODI Series - English',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'STEN1-INDENG-ODI',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('India-England Cricket Series'),
                                MediaChannelId = medPropMap.get('Sony TEN1 HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 9.7,
                                IsLiveBroadcast = true,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(13,0,0,0),
                                EndTime = Time.newInstance(23,45,0,0),
                                StartWeekDay = null,
                                EndWeekDay = null,
                                StartDateTime = System.Today() - 3,
                                EndDateTime = System.Today() + 30
        );

        objList.add(spec8);
        adSpecPriceMap.put(spec8.AdServerAdSpaceIdentifier,'50$OneTime');

        AdSpaceSpecification spec9 = new AdSpaceSpecification(
                                Name = 'Ind vs Eng 5 match ODI Series - Hindi',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'STEN2-INDENG-ODI',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('India-England Cricket Series'),
                                MediaChannelId = medPropMap.get('Sony TEN2 HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 9.5,
                                IsLiveBroadcast = true,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(13,0,0,0),
                                EndTime = Time.newInstance(23,45,0,0),
                                StartWeekDay = null,
                                EndWeekDay = null,
                                StartDateTime = System.Today() - 3,
                                EndDateTime = System.Today() + 30
        );

        objList.add(spec9);
        adSpecPriceMap.put(spec9.AdServerAdSpaceIdentifier,'40$OneTime');

        AdSpaceSpecification spec10 = new AdSpaceSpecification(
                                Name = 'Ashes Eng-Aus 5 match Test Series - English',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'STEN1-ASHES-ENGAUS',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('England-Australia Ashes Series'),
                                MediaChannelId = medPropMap.get('Sony TEN1 HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 9.8,
                                IsLiveBroadcast = true,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(3,40,0,0),
                                EndTime = Time.newInstance(12,45,0,0),
                                StartWeekDay = null,
                                EndWeekDay = null,
                                StartDateTime = System.Today() + 30,
                                EndDateTime = System.Today() + 80
        );

        objList.add(spec10);
        adSpecPriceMap.put(spec10.AdServerAdSpaceIdentifier,'50$OneTime');

        AdSpaceSpecification spec11 = new AdSpaceSpecification(
                                Name = 'Ashes Eng-Aus 5 match Test Series - Hindi',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'STEN2-ASHES-ENGAUS',
                                AdServerId = BMSAdServerId,
                                MediaContentTitleId = medContMap.get('England-Australia Ashes Series'),
                                MediaChannelId = medPropMap.get('Sony TEN2 HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 9.6,
                                IsLiveBroadcast = true,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(3,40,0,0),
                                EndTime = Time.newInstance(12,45,0,0),
                                StartWeekDay = null,
                                EndWeekDay = null,
                                StartDateTime = System.Today() + 30,
                                EndDateTime = System.Today() + 80
        );

        objList.add(spec11);
        adSpecPriceMap.put(spec11.AdServerAdSpaceIdentifier,'40$OneTime');

        AdSpaceSpecification spec12 = new AdSpaceSpecification(
                                Name = 'RODP MON-FRI 1800-2100',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SET-RODP-MF-1800-2100',
                                AdServerId = BMSAdServerId,
                                MediaChannelId = medPropMap.get('Sony SET HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 7.6,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Prime Time',
                                StartTime = Time.newInstance(18,00,0,0),
                                EndTime = Time.newInstance(21,00,0,0),
                                StartWeekDay = 'Monday',
                                EndWeekDay = 'Friday',
                                StartDateTime = System.Today() - 30,
                                EndDateTime = System.Today() + 90
        );

        objList.add(spec12);
        adSpecPriceMap.put(spec12.AdServerAdSpaceIdentifier,'30$OneTime');

        AdSpaceSpecification spec13 = new AdSpaceSpecification(
                                Name = 'RODP SAT-SUN 1300-2100',
                                Type = 'Scheduled Program',
                                AdServerAdSpaceIdentifier = 'SPIX-RODP-SS-1300-2100',
                                AdServerId = BMSAdServerId,
                                MediaChannelId = medPropMap.get('Sony PIX HD'),
                                AdSpaceType = 'Spot Buy',
                                AudienceSizeRating = 6.6,
                                IsLiveBroadcast = false,
                                ProgramRunType = 'Regular',
                                PublisherDayPart = 'Non Prime Time',
                                StartTime = Time.newInstance(13,00,0,0),
                                EndTime = Time.newInstance(21,00,0,0),
                                StartWeekDay = 'Saturday',
                                EndWeekDay = 'Sunday',
                                StartDateTime = System.Today() - 30,
                                EndDateTime = System.Today() + 90
        );

        objList.add(spec13);
        adSpecPriceMap.put(spec13.AdServerAdSpaceIdentifier,'20$OneTime');

        insert objList;

        Id priceListId = [SELECT ID FROM vlocity_cmt__PriceList__c WHERE vlocity_cmt__Code__c = 'ADSALES-PRICELIST'].Id;
        system.debug(createOrFetchPricingElements(priceListId)); //It would most likely insert the Pricing Elements in the first call.

        for(SObject obj : objList) 
        {
            AdSpaceSpecification adspecObj = (AdSpaceSpecification) obj;
            associateAdSpecWithProduct(adspecObj.Id,linearObjClassId,adSpecPriceMap.get(adspecObj.AdServerAdSpaceIdentifier),priceListId);
        }
        
        objList.clear();
    }

    @future
    public static void associateAdSpecWithProduct(Id adSpecId, String linearObjClassId, String priceCode, Id priceListId)
    {
        try
        {
            AdSpaceSpecification adSpec = [SELECT ID, Name, AdServerAdSpaceIdentifier, StartDateTime, EndDateTime, Product2Id 
                                                                    FROM AdSpaceSpecification
                                                                    WHERE ID =:adSpecId FOR UPDATE]; 
                                                                        
            //Create Product for the AdSpacepSpec
            Map<String, Object> inputs = new Map<String, Object>();
            Map<String,Object> entity = new Map<String,Object>{
                'vlocity_cmt__IsOrderable__c' => true,
                'vlocity_cmt__IsNotAssetizable__c' => false,
                'vlocity_cmt__Status__c' => 'Active',
                'IsActive' => true,
                'vlocity_cmt__ObjectTypeId__c' => linearObjClassId,
                'Name' => adSpec.Name,
                'ProductCode' => adSpec.AdServerAdSpaceIdentifier,
                'vlocity_cmt__Type__c' => 'TV',
                'vlocity_cmt__FulfilmentStartDate__c' => ((DateTime)System.today().addDays(-10)).getTime(),
                'vlocity_cmt__SellingStartDate__c' => ((DateTime)System.today().addDays(-10)).getTime()
            };

            inputs.put('epcRequest',new Map<String,Object>{'entity' => entity});

            Object result = vlocity_cmt.ProductConsoleControllerV2.invokeMethod('createProduct2', JSON.serialize(inputs));

            Map<String,Object> jsonResult = (Map<String,Object>)((Map<String,Object>)((List<Object>)((Map<String,Object>)((Map<String,Object>) JSON.deserializeUntyped(String.valueOf(result))).get('epcResponse')).get('entities'))[0]).get('entity');
            system.debug(LoggingLevel.DEBUG,'***** EPC CreateProduct Response : '+jsonResult);
            //Publish the Product
            inputs.clear();
            inputs.put('productId',(Id)jsonResult.get('Id'));

            result = vlocity_cmt.ProductConsoleControllerV2.invokeMethod('publishProduct', JSON.serialize(inputs));
            system.debug(LoggingLevel.DEBUG,'***** EPC PublishProduct Response : ' +result);

            //Create or Fetch PricingElements
            Map<String,String> pricingElementMap = createOrFetchPricingElements(priceListId);

            //Update AdSpaceSpec with product
            adSpec.Product2Id = (Id)jsonResult.get('Id');
            adSpec.IsActive = true;
            update adSpec;
            system.debug(LoggingLevel.DEBUG,'***** Ad Space Spec activated : ' +adSpec);

            //Create PriceList Entries
            createPricelistEntry((Id)jsonResult.get('Id'),priceListId, pricingElementMap.get(priceCode),priceCode);
        }
        catch (Exception e) 
        {
            System.debug(LoggingLevel.ERROR,'invokeMethod -> exception: '+e);
            System.debug(LoggingLevel.ERROR,'Error line number : '+ e.getLinenumber());
            System.debug(LoggingLevel.ERROR,'Error Message Occured : '+e.getStackTraceString());
        }
        
    }

    private static Map<String,String> createOrFetchPricingElements(Id priceListId)
    {
        Map<String,String> pricingElementMap = new Map<String,String>();
        String [] prArr = new String[]{'10$OneTime','20$OneTime','25$OneTime','30$OneTime','40$OneTime','50$OneTime'};
        List<vlocity_cmt__PricingElement__c> insertList = new List<vlocity_cmt__PricingElement__c>();
        Id pEleObjTypeId, pricingVarId;

        for(vlocity_cmt__PricingElement__c elem : [SELECT ID,vlocity_cmt__Code__c FROM vlocity_cmt__PricingElement__c WHERE vlocity_cmt__Code__c IN :prArr])
        {
            pricingElementMap.put(elem.vlocity_cmt__Code__c,elem.Id);
        }

        if(pricingElementMap.keySet().size() != prArr.size())
        {
            pEleObjTypeId = [SELECT ID FROM vlocity_cmt__ObjectClass__c WHERE vlocity_cmt__IsActive__c = true AND NAME = 'Charge' LIMIT 1].Id;
            pricingVarId = [SELECT ID FROM vlocity_cmt__PricingVariable__c WHERE vlocity_cmt__Code__c = 'OT_STD_PRC' LIMIT 1].Id;
        }
        
        for(String ele : prArr)
        {
            if(!pricingElementMap.containsKey(ele))
            {
                vlocity_cmt__PricingElement__c newElem = new vlocity_cmt__PricingElement__c(
                    vlocity_cmt__Amount__c = Double.valueOf(ele.substringBefore('$')),
                    vlocity_cmt__CalculationType__c = 'Simple',
                    vlocity_cmt__Code__c = ele,
                    vlocity_cmt__CurrencyCode__c = 'USD',
                    vlocity_cmt__DisplayText__c = ele.substringBefore('OneTime'),
                    vlocity_cmt__EffectiveFromDate__c = System.Now() - 30,
                    vlocity_cmt__IsActive__c = true,
                    vlocity_cmt__IsOverride__c = false,
                    vlocity_cmt__IsReusable__c = true,
                    vlocity_cmt__LoyaltyCode__c = 'PTS',
                    vlocity_cmt__ObjectTypeId__c = pEleObjTypeId,
                    vlocity_cmt__PerUsageAmount__c = 1.00,
                    vlocity_cmt__PriceListId__c = priceListId,
                    vlocity_cmt__PricingVariableId__c = pricingVarId,
                    Name = Integer.valueOf(ele.substringBefore('$')) + '$ One Time'
                );
                insertList.add(newElem);
            }
        }

        if(!insertList.isEmpty())
        {
            insert insertList;

            for(vlocity_cmt__PricingElement__c obj : insertList)
            {
                pricingElementMap.put(obj.vlocity_cmt__Code__c,obj.Id);
            }
        }
        system.debug(LoggingLevel.DEBUG, '****'+pricingElementMap);
        return pricingElementMap;
    }
    private static void createPricelistEntry(Id productId, Id priceListId, String pricingElement, String adSpecPrice)
    {
         system.debug(LoggingLevel.DEBUG, '****'+pricingElement);
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String,Object> entity = new Map<String,Object>{
            'vlocity_cmt__ProductId__c' => productId,
            'vlocity_cmt__PriceListId__c' => priceListId,
            'vlocity_cmt__PricingElementId__c' => pricingElement,
            'vlocity_cmt__DisplayText__c' => Integer.valueOf(adSpecPrice.substringBefore('$')) + '$ One Time',
            'vlocity_cmt__IsBasePrice__c' => true,
            'vlocity_cmt__IsVirtualPrice__c' => false,
            'vlocity_cmt__IsActive__c' => 'true',
            'vlocity_cmt__EffectiveFromDate__c' => String.valueOf(System.Now()-30)
        };

        inputs.put('epcRequest',new Map<String,Object>{'entity' => entity});

        String methodName = 'addPriceListEntry';
        Object result = vlocity_cmt.ProductConsoleControllerV2.invokeMethod(methodName, JSON.serialize(inputs));

        system.debug(LoggingLevel.DEBUG, '**** PriceListEntry create response : ' +result);

    }
    public class AsyncCreationOfPricelistEntries implements Queueable {
        Id productId;
        Id priceListId;
        String pricingElement;
        String adSpecPrice;

		public AsyncCreationOfPricelistEntries(Id productId, Id priceListId, String pricingElement, String adSpecPrice) {
			this.productId = productId;
            this.priceListId = priceListId;
            this.pricingElement = pricingElement;
            this.adSpecPrice = adSpecPrice;
		}

		public void execute(QueueableContext context) {
			createPriceListEntries();
		}
        private void createPriceListEntries(){
            system.debug(LoggingLevel.DEBUG, '****'+pricingElement);
        	Map<String, Object> inputs = new Map<String, Object>();
       		Map<String,Object> entity = new Map<String,Object>{
           	 'vlocity_cmt__ProductId__c' => productId,
           	 'vlocity_cmt__PriceListId__c' => priceListId,
           	 'vlocity_cmt__PricingElementId__c' => pricingElement,
             'vlocity_cmt__DisplayText__c' => Integer.valueOf(adSpecPrice.substringBefore('$')) + '$ One Time',
             'vlocity_cmt__IsBasePrice__c' => true,
             'vlocity_cmt__IsVirtualPrice__c' => false,
             'vlocity_cmt__IsActive__c' => 'true',
             'vlocity_cmt__EffectiveFromDate__c' => String.valueOf(System.Now()-30)
            };

        	inputs.put('epcRequest',new Map<String,Object>{'entity' => entity});

        	String methodName = 'addPriceListEntry';
        	Object result = vlocity_cmt.ProductConsoleControllerV2.invokeMethod(methodName, JSON.serialize(inputs));

        	system.debug(LoggingLevel.DEBUG, '**** PriceListEntry create response : ' +result);
        }
    }
    
    private void checkAndInsertASMMapper(Map<String,Object> input)
    {
        checkAndInsertObjectMapper();
        checkAndInsertFieldMapper((List<String>)input.get('placementMapperList'));
    }

    private void checkAndInsertObjectMapper()
    {
        List<vlocity_cmt__CustomObjectMap__c> objMapper = [SELECT Id, Name FROM vlocity_cmt__CustomObjectMap__c 
                                                        WHERE vlocity_cmt__SourceParentObject__c = 'QuoteLineItem' 
                                                        AND vlocity_cmt__SourceChildObject__c = 'AdQuoteLine' LIMIT 1];
        if(objMapper.isEmpty())
        {
            vlocity_cmt__CustomObjectMap__c asmObjMap = new vlocity_cmt__CustomObjectMap__c(
                Name = 'SIC_QLI>OI',
                vlocity_cmt__SourceParentObject__c = 'QuoteLineItem',
                vlocity_cmt__SourceChildObject__c = 'AdQuoteLine',
                vlocity_cmt__DestinationParentObject__c = 'OrderItem',
                vlocity_cmt__DestinationChildObject__c = 'AdOrderItem',
                vlocity_cmt__ParentDestinationReferenceField__c = 'OrderItemId',
                vlocity_cmt__ParentSourceReferenceField__c = 'QuoteLineItemId'
            );

            insert asmObjMap;

            System.debug(LoggingLevel.DEBUG,'**** Object Mapper for ASM Core Created');
        } 
        else 
        {
            System.debug(LoggingLevel.DEBUG,'**** Object Mapper for ASM Core Present');    
        }
    }
    private void checkAndInsertFieldMapper(List<String> placementMapperList)
    {
        List<vlocity_cmt__CustomFieldMap__c> allFieldMapperList = [SELECT ID, vlocity_cmt__DestinationFieldName__c, vlocity_cmt__DestinationSObjectType__c, vlocity_cmt__SourceFieldName__c, vlocity_cmt__SourceFieldType__c, vlocity_cmt__SourceSObjectType__c FROM vlocity_cmt__CustomFieldMap__c];
        Map<String, List<String>> fieldMapperMap = new Map<String, List<String>>();

        for(vlocity_cmt__CustomFieldMap__c mapper : allFieldMapperList)
        {
            if(fieldMapperMap.containsKey(mapper.vlocity_cmt__SourceSObjectType__c))
            {
                List<String> tmpList = fieldMapperMap.get(mapper.vlocity_cmt__SourceSObjectType__c);
                tmpList.add(mapper.vlocity_cmt__SourceFieldName__c +'=>' + mapper.vlocity_cmt__DestinationFieldName__c);
                fieldMapperMap.put(mapper.vlocity_cmt__SourceSObjectType__c, tmpList);
            } 
            else 
            {
                fieldMapperMap.put(mapper.vlocity_cmt__SourceSObjectType__c, new List<String>{mapper.vlocity_cmt__SourceFieldName__c +'=>' + mapper.vlocity_cmt__DestinationFieldName__c});    
            }  
        }
        
        objList = new List<SObject>();
        vlocity_cmt__CustomFieldMap__c record;

        if(fieldMapperMap.containsKey('Quote') && !fieldMapperMap.get('Quote').contains('Id=>QuoteId'))
        {
            //insert Quote.Id to Order.QuoteId mapping
            record = new vlocity_cmt__CustomFieldMap__c(
                Name = 'SIC_QuoteId>OrderQuoteId',
                vlocity_cmt__SourceSObjectType__c = 'Quote',
                vlocity_cmt__DestinationSObjectType__c = 'Order',
                vlocity_cmt__SourceFieldName__c = 'Id',
                vlocity_cmt__DestinationFieldName__c = 'QuoteId',
                vlocity_cmt__SourceFieldType__c = 'id',
                vlocity_cmt__SourceFieldSObjectType__c = null
            );
            objList.add(record);
        }

        if(fieldMapperMap.containsKey('QuoteLineItemId') && !fieldMapperMap.get('QuoteLineItemId').contains('Id=>QuoteLineItemId'))
        {
            //insert QuoteLineItemId.Id to OrderItem.QuoteLineItemId mapping
            record = new vlocity_cmt__CustomFieldMap__c(
                Name = 'SIC_QLIId>OIQLI',
                vlocity_cmt__SourceSObjectType__c = 'QuoteLineItem',
                vlocity_cmt__DestinationSObjectType__c = 'OrderItem',
                vlocity_cmt__SourceFieldName__c = 'Id',
                vlocity_cmt__DestinationFieldName__c = 'QuoteLineItemId',
                vlocity_cmt__SourceFieldType__c = 'id',
                vlocity_cmt__SourceFieldSObjectType__c = null
            );
            objList.add(record);
        }

        //insert Media Plan Placement to Order Ad Placement mapping
        List<String> defaultPlacementMapper = new List<String>{'Name=>Name','MediaType=>MediaType',
                                                'QuoteLineItemId=>QuoteLineItemId','AdRequestedStartDate=>AdRequestedStartDate',
                                                'AdRequestedEndDate=>AdRequestedEndDate','IsAdBleedEnabled=>IsAdBleedEnabled',
                                                'AdBleedAmountUom=>AdBleedAmountUom','AdCreativeUrl=>AdCreativeUrl',
                                                'AdCreativeSizeTypes=>AdCreativeSizeTypes','AdBleedAmount=>AdBleedAmount',
                                                'MaximumFrequency=>MaximumFrequency','MaximumFrequencyInterval=>MaximumFrequencyInterval',
                                                'MaximumUserFrequency=>MaximumUserFrequency','MaximumUserFrequencyInterval=>MaximumUserFrequencyInterval',
                                                'TargetingParameters=>TargetingParameters','UserEngagementGoalType=>UserEngagementGoalType',
                                                'UserEngagementGoalUnit=>UserEngagementGoalUnit','AdPlacementPriorityType=>AdPlacementPriorityType',
                                                'AdSpaceSpecificationId=>AdSpaceSpecificationId','UserEngagementGoalUnitType=>UserEngagementGoalUnitType',
                                                'PaidAdTime=>PaidAdTime','ImpliedTotal=>ImpliedTotal','CustomerDayPart=>CustomerDayPart',
                                                'SponsorshipType=>SponsorshipType','TotalAdTime=>TotalAdTime','GrossRatingPoint=>GrossRatingPoint',
                                                'ImpliedRate=>ImpliedRate','BonusAdTime=>BonusAdTime','CostPerRatingPoint=>CostPerRatingPoint'
                                            };
        
        List<String> existingMapping = new List<String>();
        List<String> mappingList = (placementMapperList == null || placementMapperList.isEmpty()) ? defaultPlacementMapper : placementMapperList;
        if(fieldMapperMap.containsKey('AdQuoteLine'))
        {
            existingMapping = fieldMapperMap.get('AdQuoteLine');
        }

        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('AdQuoteLine').getDescribe().fields.getMap();
        
        for(String str : mappingList)
        {
            if(!existingMapping.contains(str))
            {
                String srcField = str.substringBefore('=>');
                String destField = str.substringAfter('=>');
                schema.describefieldresult dfield = fieldMap.get(srcField).getDescribe();

                record = new vlocity_cmt__CustomFieldMap__c(
                    Name = ('SIC_' + srcField + '>' + destField).left(38),
                    vlocity_cmt__SourceSObjectType__c = 'AdQuoteLine',
                    vlocity_cmt__DestinationSObjectType__c = 'AdOrderItem',
                    vlocity_cmt__SourceFieldName__c = srcField,
                    vlocity_cmt__DestinationFieldName__c = destField,
                    vlocity_cmt__SourceFieldType__c = String.valueOf(dfield.getType()),
                    vlocity_cmt__SourceFieldSObjectType__c = dfield.getReferenceTo().isEmpty() ? null : String.valueOf(dfield.getReferenceTo()[0])
                );
                objList.add(record);
            }
        }
        
        if(!objList.isEmpty())
        {
            insert objList;
            System.debug(LoggingLevel.DEBUG,'**** ASM Placement Field Mapper inserted');
        }
    }

}