@isTest(SeeAllData=false)
private class AdSales236MigratorTest{
    private static String NAMESPACE_PREFIX = 'vlocity_cmt__';
    private static Account testAccount;
    private static Contact testContact;
            
    @TestSetup
    static void makeData(){
        testAccount = new Account(Name = 'TestAccount',Type = 'Advertiser');
        insert testAccount;
        testContact = new Contact(LastName = 'Test Contact');
        insert testContact;

        Product2 pdt = new Product2(Name='Test Product');
        insert pdt;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);        
        PriceBookEntry pbEntStan = new PriceBookEntry(PriceBook2Id = standardPriceBook.id,Product2Id = pdt.Id, UnitPrice = 5, isActive = true);
        insert pbEntStan;
        PriceBook2 pb = new PriceBook2(Name = 'TestPB');
        insert pb;
        PriceBookEntry pbEnt = new PriceBookEntry(PriceBook2Id = pb.id,Product2Id = pdt.Id, UnitPrice = 5, isActive = True);
        insert pbEnt;
        Order ord = new Order(AccountId = testAccount.Id, Status = 'Draft', EffectiveDate = System.today(), PriceBook2Id = pb.Id);
        insert ord;
        OrderItem oi = new OrderItem(OrderId = ord.Id, PriceBookEntryId = pbEnt.Id, UnitPrice = 4,Quantity = 1);
        insert oi;
        
        Opportunity testOpp = new Opportunity(Name ='testOpp', AccountId = testAccount.Id, StageName = 'test stage', CloseDate = Date.today());
        insert testOpp;
        Quote q = new Quote(Name='Test Quote 1', OpportunityId = testOpp.Id, Status= 'Draft', Pricebook2Id=Test.getStandardPricebookId());
        insert q;
        QuoteLineItem quoteLineItem = new QuoteLineItem(QuoteId = q.Id, PricebookEntryId = pbEntStan.Id, Quantity = 1, UnitPrice = 100, vlocity_cmt__Action__c = 'Add');
        insert quoteLineItem;
        
        List<SObject> adServersCustom =  createAdServerCustomObj();
        List<SObject> adCreativeSizeTypeCustom = createAdCreativeSizeTypeCustomObj();
        List<SObject> mediaPropertyCustom = createMediaPropertyCustomObj();
		List<SObject> mediaContentTitleCustom = createMediaContentTitleCustomObj();
        List<SObject> adSpaceSpecCustom = createAdSpaceSpecCustomObj(adServersCustom, pdt, mediaContentTitleCustom, mediaPropertyCustom);
		List<SObject> accountAdserverCustom = createAccountAdServerCustomObj(adServersCustom);
		List<SObject> userAdServerCustom = createUserAdServerCustomObj(adServersCustom);
		List<SObject> adSpaceCreativeSizeTypeCustom = createAdSpaceCreativeSizeTypeCustomObj(adSpaceSpecCustom, adCreativeSizeTypeCustom);
        List<SObject> adSpaceGroupMemberCustom = createAdSpaceGroupMemberCustomObj(adSpaceSpecCustom);
        
        List<SObject> quoteLineItemAdPlacementCustom = createQuoteLineItemAdPlacementCustomObj(q, quoteLineItem, adCreativeSizeTypeCustom, adSpaceSpecCustom);
        List<SObject> orderItemAdPlacementCustom = createOrderItemAdPlacementCustomObj(ord, oi, quoteLineItem, adCreativeSizeTypeCustom, adSpaceSpecCustom);
    }

    private static List<SObject> createAdServerCustomObj(){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType adServerSObjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'AdServer__c');
        if (adServerSObjectType == null) {
            return null;
        }
        SObject as1 = adServerSObjectType.newSObject();
        as1.put('Name', 'Test AdServer 1');
        as1.put(NAMESPACE_PREFIX+'AdServerApplicationName__c', '001A');
        as1.put(NAMESPACE_PREFIX+'AdServerNetworkIdentifier__c', '001B');
        as1.put(NAMESPACE_PREFIX+'AllowedAdPriorityTypes__c', 'Standard');
        as1.put(NAMESPACE_PREFIX+'NamedCredentialReference__c', '001C');

        sObjList.add(as1);
        SObject as2 = adServerSObjectType.newSObject();
        as2.put('Name', 'Test AdServer 2');
        as2.put(NAMESPACE_PREFIX+'AdServerApplicationName__c', '002A');
        as2.put(NAMESPACE_PREFIX+'AdServerNetworkIdentifier__c', '002B');
        as2.put(NAMESPACE_PREFIX+'AllowedAdPriorityTypes__c', 'Standard');
        as2.put(NAMESPACE_PREFIX+'NamedCredentialReference__c', '002C');
        sObjList.add(as2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createAdCreativeSizeTypeCustomObj(){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType adCreativeSizeTypeSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'AdCreativeSizeType__c');
        if (adCreativeSizeTypeSobjectType == null) {
            return null;
        }
        SObject acst1 = adCreativeSizeTypeSobjectType.newSObject();
        acst1.put('Name', 'Test AdCreativeSizeType 1');
        acst1.put(NAMESPACE_PREFIX+'UnitOfMeasure__c', 'Pixels');
        acst1.put(NAMESPACE_PREFIX+'MediaType__c', 'TV');
        sObjList.add(acst1);
        SObject acst2 = adCreativeSizeTypeSobjectType.newSObject();
        acst2.put('Name', 'Test AdCreativeSizeType 2');
        acst2.put(NAMESPACE_PREFIX+'UnitOfMeasure__c', 'Inches');
        acst2.put(NAMESPACE_PREFIX+'MediaType__c', 'Digital Banner');
        sObjList.add(acst2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createMediaPropertyCustomObj(){
        List<SObject> sObjList = new List<SObject>();
		Schema.SObjectType mediaPropertySobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'MediaProperty__c');
        if (mediaPropertySobjectType == null) {
            return null;
        }
        SObject mp1 = mediaPropertySobjectType.newSObject();
        mp1.put('Name', 'Test MediaChannel 1');
        mp1.put(NAMESPACE_PREFIX+'AvailableLanguages__c','English');
        mp1.put(NAMESPACE_PREFIX+'MediaType__c', 'TV');
        mp1.put(NAMESPACE_PREFIX+'PricingCategory__c', 'Standard');
        mp1.put(NAMESPACE_PREFIX+'PublicationFrequency__c', 'Daily');
        mp1.put(NAMESPACE_PREFIX+'PublisherId__c', testAccount.Id);
        mp1.put(NAMESPACE_PREFIX+'PublisherPrimaryContactId__c', testContact.Id);
        sObjList.add(mp1);
        SObject mp2 = mediaPropertySobjectType.newSObject();
        mp2.put('Name', 'Test MediaChannel 2');
        mp2.put(NAMESPACE_PREFIX+'AvailableLanguages__c','English');
        mp2.put(NAMESPACE_PREFIX+'MediaType__c', 'Digital');
        mp2.put(NAMESPACE_PREFIX+'PricingCategory__c', 'Premium');
        mp2.put(NAMESPACE_PREFIX+'PublicationFrequency__c', 'Weekly');
        mp2.put(NAMESPACE_PREFIX+'PublisherId__c', testAccount.Id);
        mp2.put(NAMESPACE_PREFIX+'PublisherPrimaryContactId__c', testContact.Id);
        sObjList.add(mp2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createMediaContentTitleCustomObj(){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType mediaContentTitleSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'MediaContentTitle__c');
        if (mediaContentTitleSobjectType == null) {
            return null;
        }
        SObject mct1 = mediaContentTitleSobjectType.newSObject();
        mct1.put('Name', 'Test MediaContentTitle 1');
        mct1.put(NAMESPACE_PREFIX+'AvailableLanguages__c', 'English');
        mct1.put(NAMESPACE_PREFIX+'Description__c', 'Test desciption');
        mct1.put(NAMESPACE_PREFIX+'Genre__c', 'Soap Opera');
        mct1.put(NAMESPACE_PREFIX+'NumberOfEpisodes__c', 6);
		sObjList.add(mct1);
        SObject mct2 = mediaContentTitleSobjectType.newSObject();
        mct2.put('Name', 'Test MediaContentTitle 2');
        mct2.put(NAMESPACE_PREFIX+'AvailableLanguages__c', 'English');
        mct2.put(NAMESPACE_PREFIX+'Description__c', 'Test Description');
        mct2.put(NAMESPACE_PREFIX+'Genre__c', 'Movie');
        mct2.put(NAMESPACE_PREFIX+'NumberOfEpisodes__c',  1);
		sObjList.add(mct2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createAdSpaceSpecCustomObj(List<SObject> adServers, Product2 pdt, List<SObject> mediaContentTitles, List<SObject> mediaProps){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType adSpaceSpecSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'AdSpaceSpecification__c');
        if (adSpaceSpecSobjectType == null) {
            return null;
        }
        SObject ass1 = adSpaceSpecSobjectType.newSObject();
        ass1.put('Name', 'Test AdSpaceSpecification 1');
        ass1.put(NAMESPACE_PREFIX+'AdServerId__c', (adServers.get(0)).get('id'));
        ass1.put(NAMESPACE_PREFIX+'IsActive__c', true);
        ass1.put(NAMESPACE_PREFIX+'Product2Id__c', pdt.get('id'));
        ass1.put(NAMESPACE_PREFIX+'AdSpaceType__c', 'Skyscraper');
        ass1.put(NAMESPACE_PREFIX+'AdServerAdSpaceIdentifier__c', '0px00000000000001');
        ass1.put(NAMESPACE_PREFIX+'AudienceSizeRating__c', 5);
        ass1.put(NAMESPACE_PREFIX+'EndDateTime__c', Datetime.newInstance(2021, 12, 31));
        ass1.put(NAMESPACE_PREFIX+'EndTime__c', Time.newInstance(18, 30, 2, 20));
        ass1.put(NAMESPACE_PREFIX+'EndWeekDay__c', 'Sunday');
        ass1.put(NAMESPACE_PREFIX+'IsLiveBroadcast__c', false);
        ass1.put(NAMESPACE_PREFIX+'MediaContentTitleId__c', (mediaContentTitles.get(0)).get('id'));
        ass1.put(NAMESPACE_PREFIX+'MediaPropertyId__c', (mediaProps.get(0)).get('id'));
        ass1.put(NAMESPACE_PREFIX+'ProgramRunType__c', 'Regular');
        ass1.put(NAMESPACE_PREFIX+'PublisherDayPart__c', 'Prime Time');
        ass1.put('RecordTypeId', '012RO0000004P3RYAU');
        ass1.put(NAMESPACE_PREFIX+'StartDateTime__c', Datetime.newInstance(2021, 11, 1));
        ass1.put(NAMESPACE_PREFIX+'StartTime__c', Time.newInstance(18, 30, 0, 0));
        ass1.put(NAMESPACE_PREFIX+'StartWeekDay__c', 'Sunday');
        sObjList.add(ass1);
        
        SObject ass2 = adSpaceSpecSobjectType.newSObject();
        ass2.put('Name', 'Test AdSpaceSpecification 2');
        ass2.put(NAMESPACE_PREFIX+'AdServerId__c', (adServers.get(1)).get('id'));
        ass2.put(NAMESPACE_PREFIX+'IsActive__c', true);
        ass2.put(NAMESPACE_PREFIX+'Product2Id__c', pdt.get('id'));
        ass2.put(NAMESPACE_PREFIX+'AdSpaceType__c', 'Leaderboard');
        ass2.put(NAMESPACE_PREFIX+'AdServerAdSpaceIdentifier__c', '0px00000000000002');
        ass2.put(NAMESPACE_PREFIX+'AudienceSizeRating__c', 4);
        ass2.put(NAMESPACE_PREFIX+'EndDateTime__c', Datetime.newInstance(2021, 12, 31));
        ass2.put(NAMESPACE_PREFIX+'EndTime__c', Time.newInstance(10, 30, 2, 20));
        ass2.put(NAMESPACE_PREFIX+'EndWeekDay__c', 'Monday');
        ass2.put(NAMESPACE_PREFIX+'IsLiveBroadcast__c', true);
        ass2.put(NAMESPACE_PREFIX+'MediaContentTitleId__c', (mediaContentTitles.get(1)).get('id'));
        ass2.put(NAMESPACE_PREFIX+'MediaPropertyId__c', (mediaProps.get(1)).get('id'));
        ass2.put(NAMESPACE_PREFIX+'ProgramRunType__c', 'Repeat');
        ass2.put(NAMESPACE_PREFIX+'PublisherDayPart__c', 'Prime Time');
        ass2.put('RecordTypeId', '012RO0000004P3SYAU');
        ass2.put(NAMESPACE_PREFIX+'StartDateTime__c', Datetime.newInstance(2021, 11, 5));
        ass2.put(NAMESPACE_PREFIX+'StartTime__c', Time.newInstance(18, 10, 0, 0));
        ass2.put(NAMESPACE_PREFIX+'StartWeekDay__c', 'Friday');
        sObjList.add(ass2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createAccountAdServerCustomObj(List<Sobject> adServers){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType accountAdServerSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'AccountAdServer__c');
        if (accountAdServerSobjectType == null) {
            return null;
        }
        SObject aas1 = accountAdServerSobjectType.newSObject();
        aas1.put('Name', 'Test AdServerAccount 1');
        aas1.put(NAMESPACE_PREFIX+'AdvertiserId__c', testAccount.id);
        aas1.put(NAMESPACE_PREFIX+'AdServerAdvertiserIdentifier__c', '0px00000000001');
        aas1.put(NAMESPACE_PREFIX+'AdServerId__c', (adServers.get(0)).get('id'));
        sObjList.add(aas1);
        SObject aas2 = accountAdServerSobjectType.newSObject();
        aas2.put('Name', 'Test AdServerAccount 2');
        aas2.put(NAMESPACE_PREFIX+'AdvertiserId__c', testAccount.id);
        aas2.put(NAMESPACE_PREFIX+'AdServerAdvertiserIdentifier__c', '0px00000000002');
        aas2.put(NAMESPACE_PREFIX+'AdServerId__c', (adServers.get(1)).get('id'));
        sObjList.add(aas2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createUserAdServerCustomObj(List<Sobject> adServers){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType userAdServerSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'UserAdServer__c');
         if (userAdServerSobjectType == null) {
            return null;
        }
        SObject uas1 = userAdServerSobjectType.newSObject();
        uas1.put('Name', 'Test AdServerUser 1');
        uas1.put(NAMESPACE_PREFIX + 'AdServerUserIdentifier__c', '0qx000000001');
		uas1.put(NAMESPACE_PREFIX + 'AdServerId__c', (adServers.get(0)).get('id'));
		sObjList.add(uas1);
        SObject uas2 = userAdServerSobjectType.newSObject();
        uas2.put('Name', 'Test AdServerUser 2');
        uas2.put(NAMESPACE_PREFIX + 'AdServerUserIdentifier__c', '0qx000000002');
		uas2.put(NAMESPACE_PREFIX + 'AdServerId__c', (adServers.get(1)).get('id'));
        sObjList.add(uas2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createAdSpaceCreativeSizeTypeCustomObj(List<SObject> adSpaceSpecSobjectType, List<SObject> adCreativeSizeTypes){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType ascstSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'AdSpaceCreativeSizeType__c');
        if (ascstSobjectType == null) {
            return null;
        }
        SObject ascst1 = ascstSobjectType.newSObject();
        ascst1.put('Name', 'Test AdSpaceCreativeSizeType 1');
        ascst1.put(NAMESPACE_PREFIX+'AdSpaceSpecificationId__c', (adSpaceSpecSobjectType.get(0)).get('id'));
        ascst1.put(NAMESPACE_PREFIX+'AdCreativeSizeTypeId__c', (adCreativeSizeTypes.get(0)).get('id'));
        sObjList.add(ascst1);
        SObject ascst2 = ascstSobjectType.newSObject();
        ascst2.put('Name', 'Test AdSpaceCreativeSizeType 2');
        ascst2.put(NAMESPACE_PREFIX+'AdSpaceSpecificationId__c', (adSpaceSpecSobjectType.get(1)).get('id'));
        ascst2.put(NAMESPACE_PREFIX+'AdCreativeSizeTypeId__c', (adCreativeSizeTypes.get(1)).get('id'));
        sObjList.add(ascst2);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createAdSpaceGroupMemberCustomObj(List<SObject> adSpaceSpecs){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType asgmSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'AdSpaceGroupMember__c');
        if (asgmSobjectType == null) {
            return null;
        }
        SObject asgm1 = asgmSobjectType.newSObject();
        asgm1.put('Name', 'Test AdSpaceGroupMember 1');
        asgm1.put(NAMESPACE_PREFIX+'AdSpaceGroupId__c', (adSpaceSpecs.get(1)).get('id'));
        asgm1.put(NAMESPACE_PREFIX+'AdSpaceGroupMemberId__c', (adSpaceSpecs.get(0)).get('id'));
        sObjList.add(asgm1);
        insert sObjList;
        return sObjList;
    }
    
    private static List<SObject> createQuoteLineItemAdPlacementCustomObj(Quote q, QuoteLineItem quoteLineItem, List<SObject> acst, List<SObject> adSpaceSpec){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType quoteLineItemAdPlacementSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'QuoteLineItemAdPlacement__c');
        if (quoteLineItemAdPlacementSobjectType == null) {
            return null;
        }
        SObject qli = quoteLineItemAdPlacementSobjectType.newSObject();
        qli.put('Name', 'Test AdQuoteLine 1');
        qli.put(NAMESPACE_PREFIX + 'IsAdBleedEnabled__c', false);
        qli.put(NAMESPACE_PREFIX + 'AdBleedAmount__c', 4);
        qli.put(NAMESPACE_PREFIX + 'AdBleedAmountUom__c', 'Pixels');
        qli.put(NAMESPACE_PREFIX + 'AdCreativeSizeTypes__c', acst.toString());
        qli.put(NAMESPACE_PREFIX + 'AdCreativeUrl__c', 'https://www.abc.com');
        qli.put(NAMESPACE_PREFIX + 'QuoteId__c', q.Id);
        qli.put(NAMESPACE_PREFIX + 'AdRequestedEndDate__c', Datetime.newInstance(2021, 12, 31));
        qli.put(NAMESPACE_PREFIX + 'AdRequestedStartDate__c', Datetime.newInstance(2021, 11, 5));
        qli.put(NAMESPACE_PREFIX + 'AdTimePerEpisode__c', 10);
        qli.put(NAMESPACE_PREFIX + 'AdPlacementPriorityType__c', 'Priority High');
        qli.put(NAMESPACE_PREFIX + 'AdSpaceSpecificationId__c', (adSpaceSpec.get(0)).get('id'));
        qli.put(NAMESPACE_PREFIX + 'BonusAdTime__c', 1);
        qli.put(NAMESPACE_PREFIX + 'CostPerRatingPoint__c', 4);
        qli.put(NAMESPACE_PREFIX + 'CustomerDayPart__c', 'Prime Time');
        qli.put(NAMESPACE_PREFIX + 'GrossRatingPoint__c', 4);
        qli.put(NAMESPACE_PREFIX + 'ImpliedRate__c', 5);
        qli.put(NAMESPACE_PREFIX + 'ImpliedTotal__c', 10);
        qli.put(NAMESPACE_PREFIX + 'MaximumFrequency__c', 4);
        qli.put(NAMESPACE_PREFIX + 'MaximumFrequencyInterval__c', 'Hour');
        qli.put(NAMESPACE_PREFIX + 'MaximumUserFrequency__c', 4);
        qli.put(NAMESPACE_PREFIX + 'MaximumUserFrequencyInterval__c', 'Hour');
        qli.put(NAMESPACE_PREFIX + 'MediaType__c', 'Digital');
        qli.put(NAMESPACE_PREFIX + 'PaidAdTime__c', 4);
        qli.put(NAMESPACE_PREFIX + 'QuoteLineItemId__c', quoteLineItem.Id);
        qli.put(NAMESPACE_PREFIX + 'SponsorshipType__c', 'Presented By');
        qli.put(NAMESPACE_PREFIX + 'TargetingParameters__c', 'Targeting Parameters');
        qli.put(NAMESPACE_PREFIX + 'TotalAdTime__c', 4);
        qli.put(NAMESPACE_PREFIX + 'UserEngagementGoalType__c', 'User Engagement Goal Type');
        qli.put(NAMESPACE_PREFIX + 'UserEngagementGoalUnit__c', 4);
        qli.put(NAMESPACE_PREFIX + 'UserEngagementGoalUnitType__c', 'User Engagement Goal Unit Type');

        sObjList.add(qli);
        insert sObjList;
        return sObjList;
    }
    private static List<SObject> createOrderItemAdPlacementCustomObj(Order ord, OrderItem oi, QuoteLineItem quoteLineItem, List<SObject> acst, List<SObject> adSpaceSpec){
        List<SObject> sObjList = new List<SObject>();
        Schema.SObjectType orderItemAdPlacementSobjectType = Schema.getGlobalDescribe().get(NAMESPACE_PREFIX + 'OrderItemAdPlacement__c');
        if (orderItemAdPlacementSobjectType == null) {
            return null;
        }
        SObject oiap = orderItemAdPlacementSobjectType.newSObject();
        oiap.put('Name', 'Test AdOrderItem 1');
        oiap.put(NAMESPACE_PREFIX + 'IsAdBleedEnabled__c', false);
        oiap.put(NAMESPACE_PREFIX + 'AdBleedAmount__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'AdBleedAmountUom__c', 'Pixels');
        oiap.put(NAMESPACE_PREFIX + 'AdCreativeSizeTypes__c', acst.toString());
        oiap.put(NAMESPACE_PREFIX + 'AdCreativeUrl__c', 'https://www.abc.com');
        oiap.put(NAMESPACE_PREFIX + 'AdPlacementPriorityType__c', 'Priority High');
        oiap.put(NAMESPACE_PREFIX + 'AdRequestedEndDate__c', Datetime.newInstance(2021, 12, 31));
        oiap.put(NAMESPACE_PREFIX + 'AdRequestedStartDate__c', Datetime.newInstance(2021, 11, 5));
        oiap.put(NAMESPACE_PREFIX + 'AdServerOrderIdentifier__c', 'Ad Server External Id');
        oiap.put(NAMESPACE_PREFIX + 'AdServerOrderLineIdentiifier__c', 'Ad Server External Id');
        oiap.put(NAMESPACE_PREFIX + 'AdSpaceSpecificationId__c', (adSpaceSpec.get(0)).get('id'));
        oiap.put(NAMESPACE_PREFIX + 'AdTimePerEpisode__c', 10);
        oiap.put(NAMESPACE_PREFIX + 'BonusAdTime__c', 1);
        oiap.put(NAMESPACE_PREFIX + 'CostPerRatingPoint__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'CustomerDayPart__c', 'Prime Time');
        oiap.put(NAMESPACE_PREFIX + 'GrossRatingPoint__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'ImpliedRate__c', 5);
        oiap.put(NAMESPACE_PREFIX + 'ImpliedTotal__c', 10);
		oiap.put(NAMESPACE_PREFIX + 'MaximumFrequency__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'MaximumFrequencyInterval__c', 'Hour');
        oiap.put(NAMESPACE_PREFIX + 'MaximumUserFrequency__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'MaximumUserFrequencyInterval__c', 'Hour');
        oiap.put(NAMESPACE_PREFIX + 'MediaType__c', 'Digital');
        oiap.put(NAMESPACE_PREFIX + 'OrderId__c', ord.Id);
        oiap.put(NAMESPACE_PREFIX + 'OrderItemId__c', oi.Id);
        oiap.put(NAMESPACE_PREFIX + 'PaidAdTime__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'QuoteLineItemId__c', quoteLineItem.Id);
        oiap.put(NAMESPACE_PREFIX + 'SponsorshipType__c', 'Presented By');
		oiap.put(NAMESPACE_PREFIX + 'TargetingParameters__c', 'Targeting Parameters');
        oiap.put(NAMESPACE_PREFIX + 'TotalAdTime__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'UserEngagementGoalType__c', 'User Engagement Goal Type');
        oiap.put(NAMESPACE_PREFIX + 'UserEngagementGoalUnit__c', 4);
        oiap.put(NAMESPACE_PREFIX + 'UserEngagementGoalUnitType__c', 'User Engagement Goal Unit Type');        
        sObjList.add(oiap);
        insert sObjList;
        return sObjList;
    }
	private static String getQueryforCustomObj(String objectName) {
        String oldName = AdSalesMapper.getOldObjectName(objectName);
        String query = '';
        Map<String, String> fieldMap = AdSalesMapper.getFieldMapper(objectName);
        if(objectName.equalsIgnoreCase('AdQuote')) {
			query = 'SELECT ' + String.join(New List<String>(fieldMap.keySet()), ',') + ' FROM Quote where ID IN (SELECT ' + NAMESPACE_PREFIX + 'QuoteId__c from ' + AdSalesMapper.getOldObjectName('AdQuoteLine')+')';        }
        else {
			query = 'SELECT ' + String.join(New List<String>(fieldMap.keySet()), ',') + ',' + NAMESPACE_PREFIX +'CoreId__c' + ' FROM ' + oldName;
        }
        return query;
    }    
    @isTest
    static void testMigrateAdSalesObjectBatchAdminData(){
        Test.startTest();
        AdSales236Migrator migratorObject = new AdSales236Migrator();
        migratorObject.migrateAdminData();
        Test.stopTest();
        
        String customQuery='';
        String coreQuery = '';
        List<SObject> coreList; 
		List<SObject> customList;
        
        customQuery = getQueryforCustomObj('AdServer');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdServer LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdServerApplicationName__c'),coreObj.get('AdServerApplicationName'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdServerNetworkIdentifier__c'),coreObj.get('AdServerNetworkIdentifier'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AllowedAdPriorityTypes__c'),coreObj.get('AllowedAdPriorityTypes'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'NamedCredentialReference__c'),coreObj.get('NamedCredentialReference'));
        }
   
        customQuery = getQueryforCustomObj('AdCreativeSizeType');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdCreativeSizeType LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'UnitOfMeasure__c'),coreObj.get('UnitOfMeasure'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MediaType__c'),coreObj.get('MediaType'));
        }
        
        customQuery = getQueryforCustomObj('MediaChannel');
        coreQuery = 'SELECT Fields(STANDARD) FROM MediaChannel LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AvailableLanguages__c'),coreObj.get('AvailableLanguages'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MediaType__c'),coreObj.get('MediaType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'PricingCategory__c'),coreObj.get('PricingCategory'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'PublicationFrequency__c'),coreObj.get('PublicationFrequency'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'PublisherId__c'),coreObj.get('PublisherId'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'PublisherPrimaryContactId__c'),coreObj.get('PublisherPrimaryContactId'));
        }

        customQuery = getQueryforCustomObj('MediaContentTitle');
        coreQuery = 'SELECT Fields(STANDARD) FROM MediaContentTitle LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AvailableLanguages__c'),coreObj.get('AvailableLanguages'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'Description__c'),coreObj.get('Description'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'Genre__c'),coreObj.get('Genre'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'NumberOfEpisodes__c'),coreObj.get('NumberOfEpisodes'));
        }

        customQuery = getQueryforCustomObj('AdServerAccount');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdServerAccount LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdvertiserId__c'),coreObj.get('AdvertiserId'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdServerAdvertiserIdentifier__c'),coreObj.get('AdServerAdvertiserIdentifier'));
            String fieldVal = customObj.get(NAMESPACE_PREFIX+'AdServerId__c').toString();
            String query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+NAMESPACE_PREFIX+'AdServer__c WHERE id = :fieldVal LIMIT 1';
            SObject newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdServerId'));
        }
        
        customQuery = getQueryforCustomObj('AdServerUser');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdServerUser LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdServerUserIdentifier__c'),coreObj.get('AdServerUserIdentifier'));
            String fieldVal = customObj.get(NAMESPACE_PREFIX+'AdServerId__c').toString();
            String query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+NAMESPACE_PREFIX+'AdServer__c WHERE id = :fieldVal LIMIT 1';
            SObject newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdServerId'));
        }
        
        customQuery = getQueryforCustomObj('AdSpaceSpecification');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdSpaceSpecification LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            String fieldVal = customObj.get(NAMESPACE_PREFIX+'AdServerId__c').toString();
            String query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+NAMESPACE_PREFIX+'AdServer__c WHERE id = :fieldVal LIMIT 1';
            SObject newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdServerId'));
            
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'IsActive__c'),coreObj.get('IsActive'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'Product2Id__c'),coreObj.get('Product2Id'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'AdSpaceType__c'),coreObj.get('AdSpaceType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'AdServerAdSpaceIdentifier__c'),coreObj.get('AdServerAdSpaceIdentifier'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'AudienceSizeRating__c'),coreObj.get('AudienceSizeRating'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'EndDateTime__c'),coreObj.get('EndDateTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'EndTime__c'),coreObj.get('EndTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'EndWeekDay__c'),coreObj.get('EndWeekDay'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'IsLiveBroadcast__c'),coreObj.get('IsLiveBroadcast'));
			
            fieldVal = customObj.get(NAMESPACE_PREFIX+'MediaContentTitleId__c').toString();
            query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+ NAMESPACE_PREFIX +'MediaContentTitle__c WHERE id = :fieldVal LIMIT 1';
            newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('MediaContentTitleId'));
            fieldVal = customObj.get(NAMESPACE_PREFIX+'MediaPropertyId__c').toString();
            query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+ NAMESPACE_PREFIX +'MediaProperty__c WHERE id = :fieldVal LIMIT 1';
            newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('MediaChannelId'));
            fieldVal = customObj.get('RecordTypeId').toString();
            query  = 'SELECT Name FROM RecordType WHERE id = :fieldVal LIMIT 1';
            newMappedObj = Database.query(query);
            
            System.assertEquals(newMappedObj.get('Name'),coreObj.get('Type'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'ProgramRunType__c'),coreObj.get('ProgramRunType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'PublisherDayPart__c'),coreObj.get('PublisherDayPart'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'StartDateTime__c'),coreObj.get('StartDateTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'StartTime__c'),coreObj.get('StartTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'StartWeekDay__c'),coreObj.get('StartWeekDay'));
        }
        
        customQuery = getQueryforCustomObj('AdSpaceCreativeSizeType');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdSpaceCreativeSizeType LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            
            String fieldVal = customObj.get(NAMESPACE_PREFIX+'AdSpaceSpecificationId__c').toString();
            String query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+NAMESPACE_PREFIX+'AdSpaceSpecification__c WHERE id = :fieldVal LIMIT 1';
            SObject newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdSpaceSpecificationId'));
           
            fieldVal = customObj.get(NAMESPACE_PREFIX+'AdCreativeSizeTypeId__c').toString();
            query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+NAMESPACE_PREFIX+'AdCreativeSizeType__c WHERE id = :fieldVal LIMIT 1';
            newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdCreativeSizeTypeId'));
        }
        
        customQuery = getQueryforCustomObj('AdSpaceGroupMember');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdSpaceGroupMember LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX + 'CoreId__c'),coreObj.get('Id'));
            
            String fieldVal = customObj.get(NAMESPACE_PREFIX+'AdSpaceGroupId__c').toString();
            String query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+ NAMESPACE_PREFIX +'AdSpaceSpecification__c WHERE id = :fieldVal LIMIT 1';
            SObject newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdSpaceGroupId'));
           
            fieldVal = customObj.get(NAMESPACE_PREFIX+'AdSpaceGroupMemberId__c').toString();
            query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+ NAMESPACE_PREFIX +'AdSpaceSpecification__c WHERE id = :fieldVal LIMIT 1';
            newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdSpaceGroupMemberNameId'));
        }
    }
    @isTest
    static void testMigrateAdSalesObjectBatchNonAdminData(){
        String customQuery='';
        String coreQuery = '';
        List<SObject> coreList; 
		List<SObject> customList;
        
        Test.startTest();
        AdSales236Migrator migratorObject = new AdSales236Migrator();
        migratorObject.migrateNonAdminData();
        Test.stopTest();
       
        customQuery = getQueryforCustomObj('AdQuote');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdQuote LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get('id'),coreObj.get('QuoteId'));
        }
       
        customQuery = getQueryforCustomObj('AdQuoteLine');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdQuoteLine LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'IsAdBleedEnabled__c'),coreObj.get('IsAdBleedEnabled'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdBleedAmount__c'),coreObj.get('AdBleedAmount'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdBleedAmountUom__c'),coreObj.get('AdBleedAmountUom'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdCreativeSizeTypes__c'),coreObj.get('AdCreativeSizeTypes'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdCreativeUrl__c'),coreObj.get('AdCreativeUrl'));
            
            String fieldVal = customObj.get(NAMESPACE_PREFIX + 'QuoteId__c').toString();
            String query  = 'SELECT id FROM AdQuote where QuoteId = :fieldVal LIMIT 1';
            SObject newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get('id'),coreObj.get('AdQuoteId'));
            
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdRequestedEndDate__c'),coreObj.get('AdRequestedEndDate'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdRequestedStartDate__c'),coreObj.get('AdRequestedStartDate'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdTimePerEpisode__c'),coreObj.get('AdTimePerEpisode'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdPlacementPriorityType__c'),coreObj.get('AdPlacementPriorityType'));
            
            fieldVal = customObj.get(NAMESPACE_PREFIX + 'AdSpaceSpecificationId__c').toString();
            query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+NAMESPACE_PREFIX+'AdSpaceSpecification__c WHERE id = :fieldVal LIMIT 1';
            newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdSpaceSpecificationId'));
            
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'BonusAdTime__c'),coreObj.get('BonusAdTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'CostPerRatingPoint__c'),coreObj.get('CostPerRatingPoint'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'CustomerDayPart__c'),coreObj.get('CustomerDayPart'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'GrossRatingPoint__c'),coreObj.get('GrossRatingPoint'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'ImpliedRate__c'),coreObj.get('ImpliedRate'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'ImpliedTotal__c'),coreObj.get('ImpliedTotal'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumFrequency__c'),coreObj.get('MaximumFrequency'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumFrequencyInterval__c'),coreObj.get('MaximumFrequencyInterval'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumUserFrequency__c'),coreObj.get('MaximumUserFrequency'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumUserFrequencyInterval__c'),coreObj.get('MaximumUserFrequencyInterval'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MediaType__c'),coreObj.get('MediaType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'PaidAdTime__c'),coreObj.get('PaidAdTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'QuoteLineItemId__c'),coreObj.get('QuoteLineItemId'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'SponsorshipType__c'),coreObj.get('SponsorshipType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'TargetingParameters__c'),coreObj.get('TargetingParameters'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'TotalAdTime__c'),coreObj.get('TotalAdTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'UserEngagementGoalType__c'),coreObj.get('UserEngagementGoalType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'UserEngagementGoalUnit__c'),coreObj.get('UserEngagementGoalUnit'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'UserEngagementGoalUnitType__c'),coreObj.get('UserEngagementGoalUnitType'));
        }
     
        customQuery = getQueryforCustomObj('AdOrderItem');
        coreQuery = 'SELECT Fields(STANDARD) FROM AdOrderItem LIMIT 200';
        coreList = Database.query(coreQuery);
        customList = Database.query(customQuery);
        System.assertEquals(customList.size(), coreList.size());
        for(Integer i = 0; i<coreList.size(); i++){
            SObject coreObj = coreList.get(i);
            SObject customObj = customList.get(i);
        	System.assertEquals(customObj.get('Name'),coreObj.get('Name'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'IsAdBleedEnabled__c'),coreObj.get('IsAdBleedEnabled'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdBleedAmount__c'),coreObj.get('AdBleedAmount'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdBleedAmountUom__c'),coreObj.get('AdBleedAmountUom'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdCreativeSizeTypes__c'),coreObj.get('AdCreativeSizeTypes'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdCreativeUrl__c'),coreObj.get('AdCreativeUrl'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdPlacementPriorityType__c'),coreObj.get('AdPlacementPriorityType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdRequestedEndDate__c'),coreObj.get('AdRequestedEndDate'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdRequestedStartDate__c'),coreObj.get('AdRequestedStartDate'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdServerOrderIdentifier__c'),coreObj.get('AdServerOrderIdentifier'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdServerOrderLineIdentiifier__c'),coreObj.get('AdServerOrderLineIdentifier'));
            
            String fieldVal = customObj.get(NAMESPACE_PREFIX + 'AdSpaceSpecificationId__c').toString();
            String query  = 'SELECT ' + NAMESPACE_PREFIX + 'CoreId__c FROM '+NAMESPACE_PREFIX+'AdSpaceSpecification__c WHERE id = :fieldVal LIMIT 1';
            SObject newMappedObj = Database.query(query);
            System.assertEquals(newMappedObj.get(NAMESPACE_PREFIX+'CoreId__c'),coreObj.get('AdSpaceSpecificationId'));
            
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'AdTimePerEpisode__c'),coreObj.get('AdTimePerEpisode'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'BonusAdTime__c'),coreObj.get('BonusAdTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'CostPerRatingPoint__c'),coreObj.get('CostPerRatingPoint'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'CustomerDayPart__c'),coreObj.get('CustomerDayPart'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'GrossRatingPoint__c'),coreObj.get('GrossRatingPoint'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'ImpliedRate__c'),coreObj.get('ImpliedRate'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'ImpliedTotal__c'),coreObj.get('ImpliedTotal'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumFrequency__c'),coreObj.get('MaximumFrequency'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumFrequencyInterval__c'),coreObj.get('MaximumFrequencyInterval'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumUserFrequency__c'),coreObj.get('MaximumUserFrequency'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MaximumUserFrequencyInterval__c'),coreObj.get('MaximumUserFrequencyInterval'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'MediaType__c'),coreObj.get('MediaType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'OrderId__c'),coreObj.get('OrderId'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'OrderItemId__c'),coreObj.get('OrderItemId'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'PaidAdTime__c'),coreObj.get('PaidAdTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'QuoteLineItemId__c'),coreObj.get('QuoteLineItemId'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'SponsorshipType__c'),coreObj.get('SponsorshipType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'TargetingParameters__c'),coreObj.get('TargetingParameters'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'TotalAdTime__c'),coreObj.get('TotalAdTime'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'UserEngagementGoalType__c'),coreObj.get('UserEngagementGoalType'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'UserEngagementGoalUnit__c'),coreObj.get('UserEngagementGoalUnit'));
            System.assertEquals(customObj.get(NAMESPACE_PREFIX+'UserEngagementGoalUnitType__c'),coreObj.get('UserEngagementGoalUnitType'));   
        }    
    }
}