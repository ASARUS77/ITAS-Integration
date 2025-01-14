public with sharing class AdSalesMapper {
    public AdSalesMapper() {

    }

    public static String NAMESPACE_PREFIX = 'vlocity_cmt__';
    public static String CORE_ID_FIELD_NAME = NAMESPACE_PREFIX + 'CoreId__c';

    private static List<String> MIGRATION_ORDER_ADMIN = new List<String> {
        'AdServer', 'AdCreativeSizeType', 'MediaChannel', 'MediaContentTitle',
        'AdServerAccount', 'AdServerUser', 'AdSpaceSpecification',
        'AdSpaceCreativeSizeType', 'AdSpaceGroupMember'
    };

    private static List<String> MIGRATION_ORDER_NON_ADMIN = new List<String> {
         'AdQuote',
         'AdQuoteLine', 
         'AdOrderItem'
    };

    private static Map<String, String> OLD2NEW_OBJECT_NAME_MAP = new Map<String, String> {
        NAMESPACE_PREFIX + 'AdServer__c' => 'AdServer',
        NAMESPACE_PREFIX + 'AdCreativeSizeType__c' => 'AdCreativeSizeType',
        NAMESPACE_PREFIX + 'MediaProperty__c' => 'MediaChannel',
        NAMESPACE_PREFIX + 'MediaContentTitle__c' => 'MediaContentTitle',
        NAMESPACE_PREFIX + 'AccountAdServer__c' => 'AdServerAccount',
        NAMESPACE_PREFIX + 'UserAdServer__c' => 'AdServerUser',
        NAMESPACE_PREFIX + 'AdSpaceSpecification__c' => 'AdSpaceSpecification',
        NAMESPACE_PREFIX + 'AdSpaceCreativeSizeType__c' => 'AdSpaceCreativeSizeType',
        NAMESPACE_PREFIX + 'AdSpaceGroupMember__c' => 'AdSpaceGroupMember',
        'Quote' => 'AdQuote',
        NAMESPACE_PREFIX + 'QuoteLineItemAdPlacement__c' => 'AdQuoteLine',
        NAMESPACE_PREFIX + 'OrderItemAdPlacement__c' => 'AdOrderItem'
    };

    private static Map<String, String> NEW2OLD_OBJECT_NAME_MAP = new Map<String, String> {
        'AdServer' => NAMESPACE_PREFIX + 'AdServer__c',
        'AdCreativeSizeType' => NAMESPACE_PREFIX + 'AdCreativeSizeType__c',
        'MediaChannel' => NAMESPACE_PREFIX + 'MediaProperty__c',
        'MediaContentTitle' => NAMESPACE_PREFIX + 'MediaContentTitle__c',
        'AdServerAccount' => NAMESPACE_PREFIX + 'AccountAdServer__c',
        'AdServerUser' => NAMESPACE_PREFIX + 'UserAdServer__c',
        'AdSpaceSpecification' => NAMESPACE_PREFIX + 'AdSpaceSpecification__c',
        'AdSpaceCreativeSizeType' => NAMESPACE_PREFIX + 'AdSpaceCreativeSizeType__c',
        'AdSpaceGroupMember' => NAMESPACE_PREFIX + 'AdSpaceGroupMember__c',
        'AdQuote' => 'Quote',
        'AdQuoteLine' => NAMESPACE_PREFIX + 'QuoteLineItemAdPlacement__c',
        'AdOrderItem' => NAMESPACE_PREFIX + 'OrderItemAdPlacement__c'
    };

    private static Map<String, String> AD_SERVER_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'AdServerApplicationName__c' => 'AdServerApplicationName',
        NAMESPACE_PREFIX + 'AdServerNetworkIdentifier__c' => 'AdServerNetworkIdentifier',
        NAMESPACE_PREFIX + 'AllowedAdPriorityTypes__c' => 'AllowedAdPriorityTypes',
        NAMESPACE_PREFIX + 'NamedCredentialReference__c' => 'NamedCredentialReference'
    };

    private static Map<String, String> AD_CREATIVE_SIZE_TYPE_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'RunTime__c' => 'RunTime',
        NAMESPACE_PREFIX + 'Height__c' => 'Height',
        NAMESPACE_PREFIX + 'UnitOfMeasure__c' => 'UnitOfMeasure',
        NAMESPACE_PREFIX + 'MediaType__c' => 'MediaType',
        NAMESPACE_PREFIX + 'Width__c' => 'Width' 
    };

    private static Map<String, String> MEDIA_CHANNEL_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'AvailableLanguages__c' => 'AvailableLanguages',
        NAMESPACE_PREFIX + 'MediaType__c' => 'MediaType',
        NAMESPACE_PREFIX + 'PricingCategory__c' => 'PricingCategory',
        NAMESPACE_PREFIX + 'PublicationFrequency__c' => 'PublicationFrequency',
        NAMESPACE_PREFIX + 'PublisherId__c' => 'PublisherId',
        NAMESPACE_PREFIX + 'PublisherPrimaryContactId__c' => 'PublisherPrimaryContactId'
    };

    private static Map<String, String> MEDIA_CONTENT_TITLE_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'AvailableLanguages__c' => 'AvailableLanguages',
        NAMESPACE_PREFIX + 'Description__c' => 'Description',
        NAMESPACE_PREFIX + 'Genre__c' => 'Genre',
        NAMESPACE_PREFIX + 'NumberOfEpisodes__c' => 'NumberOfEpisodes'
    };

    private static Map<String, String> AD_SERVER_ACCOUNT_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'AdvertiserId__c' => 'AdvertiserId',
        NAMESPACE_PREFIX + 'AdServerAdvertiserIdentifier__c' => 'AdServerAdvertiserIdentifier',
        NAMESPACE_PREFIX + 'AdServerId__r.' + CORE_ID_FIELD_NAME => 'AdServerId'
    };

    private static Map<String, String> AD_SERVER_USER_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'UserId__c' => 'UserId',
        NAMESPACE_PREFIX + 'AdServerUserIdentifier__c' => 'AdServerUserIdentifier',
        NAMESPACE_PREFIX + 'AdServerId__r.' + CORE_ID_FIELD_NAME => 'AdServerId'
    };

    private static Map<String, String> AD_SPACE_SPECIFICATION_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'AdServerId__r.' + CORE_ID_FIELD_NAME => 'AdServerId',
        NAMESPACE_PREFIX + 'MediaPropertyId__r.' + CORE_ID_FIELD_NAME => 'MediaChannelId',
        NAMESPACE_PREFIX + 'AdSpaceType__c' => 'AdSpaceType',
        NAMESPACE_PREFIX + 'IsActive__c'  => 'IsActive',
        NAMESPACE_PREFIX + 'AdServerAdSpaceIdentifier__c' => 'AdServerAdSpaceIdentifier',
        'RecordType.Name' => 'Type',
        NAMESPACE_PREFIX + 'MediaContentTitleId__r.' + CORE_ID_FIELD_NAME => 'MediaContentTitleId',
        NAMESPACE_PREFIX + 'Product2Id__c' => 'Product2Id',
        NAMESPACE_PREFIX + 'StartWeekDay__c'  => 'StartWeekDay',
        NAMESPACE_PREFIX + 'EndWeekDay__c'  => 'EndWeekDay',
        NAMESPACE_PREFIX + 'StartTime__c'  => 'StartTime',
        NAMESPACE_PREFIX + 'EndTime__c'  => 'EndTime',
        NAMESPACE_PREFIX + 'AudienceSizeRating__c'  => 'AudienceSizeRating',
        NAMESPACE_PREFIX + 'ProgramRunType__c'  => 'ProgramRunType',
        NAMESPACE_PREFIX + 'PublisherDayPart__c'  => 'PublisherDayPart',
        NAMESPACE_PREFIX + 'IsLiveBroadcast__c'  => 'IsLiveBroadcast',
        NAMESPACE_PREFIX + 'StartDateTime__c'  => 'StartDateTime',
        NAMESPACE_PREFIX + 'EndDateTime__c'  => 'EndDateTime' 
    };

    private static Map<String, String> AD_SPACE_CREATIVE_SIZE_TYPE_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'AdSpaceSpecificationId__r.' + CORE_ID_FIELD_NAME => 'AdSpaceSpecificationId',
        NAMESPACE_PREFIX + 'AdCreativeSizeTypeId__r.' + CORE_ID_FIELD_NAME => 'AdCreativeSizeTypeId'
    };

    private static Map<String, String> AD_SPACE_GROUP_MEMBER_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'AdSpaceGroupId__r.' + CORE_ID_FIELD_NAME  => 'AdSpaceGroupId',
        NAMESPACE_PREFIX + 'AdSpaceGroupMemberId__r.' + CORE_ID_FIELD_NAME => 'AdSpaceGroupMemberNameId'
    };

    private static Map<String, String> AD_QUOTE_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
         'id' => 'QuoteId'       
    };

    private static Map<String, String> AD_QUOTE_LINE_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'IsAdBleedEnabled__c' => 'IsAdBleedEnabled',
        NAMESPACE_PREFIX + 'AdBleedAmount__c' => 'AdBleedAmount',
        NAMESPACE_PREFIX + 'AdBleedAmountUom__c' => 'AdBleedAmountUom',
        NAMESPACE_PREFIX + 'AdCreativeSizeTypes__c' => 'AdCreativeSizeTypes',
        NAMESPACE_PREFIX + 'AdCreativeUrl__c' => 'AdCreativeUrl',
        NAMESPACE_PREFIX + 'QuoteId__c' => 'AdQuoteId',
        NAMESPACE_PREFIX + 'AdRequestedEndDate__c' => 'AdRequestedEndDate',
        NAMESPACE_PREFIX + 'AdRequestedStartDate__c' => 'AdRequestedStartDate',
        NAMESPACE_PREFIX + 'AdTimePerEpisode__c' => 'AdTimePerEpisode',
        NAMESPACE_PREFIX + 'AdPlacementPriorityType__c' => 'AdPlacementPriorityType',
        NAMESPACE_PREFIX + 'AdSpaceSpecificationId__r.' + CORE_ID_FIELD_NAME => 'AdSpaceSpecificationId',
        NAMESPACE_PREFIX + 'BonusAdTime__c' => 'BonusAdTime',
        NAMESPACE_PREFIX + 'CostPerRatingPoint__c' => 'CostPerRatingPoint',
        NAMESPACE_PREFIX + 'CustomerDayPart__c' => 'CustomerDayPart',
        NAMESPACE_PREFIX + 'GrossRatingPoint__c' => 'GrossRatingPoint',
        NAMESPACE_PREFIX + 'ImpliedRate__c' => 'ImpliedRate',
        NAMESPACE_PREFIX + 'ImpliedTotal__c' => 'ImpliedTotal',
        NAMESPACE_PREFIX + 'MaximumFrequency__c' => 'MaximumFrequency',
        NAMESPACE_PREFIX + 'MaximumFrequencyInterval__c' => 'MaximumFrequencyInterval',
        NAMESPACE_PREFIX + 'MaximumUserFrequency__c' => 'MaximumUserFrequency',
        NAMESPACE_PREFIX + 'MaximumUserFrequencyInterval__c' =>  'MaximumUserFrequencyInterval',
        NAMESPACE_PREFIX + 'MediaType__c' => 'MediaType',
        NAMESPACE_PREFIX + 'PaidAdTime__c' => 'PaidAdTime',
        NAMESPACE_PREFIX + 'QuoteLineItemId__c' => 'QuoteLineItemId',
        NAMESPACE_PREFIX + 'SponsorshipType__c' => 'SponsorshipType',
        NAMESPACE_PREFIX + 'TargetingParameters__c' => 'TargetingParameters',
        NAMESPACE_PREFIX + 'TotalAdTime__c' => 'TotalAdTime',
        NAMESPACE_PREFIX + 'UserEngagementGoalType__c' => 'UserEngagementGoalType',
        NAMESPACE_PREFIX + 'UserEngagementGoalUnit__c' => 'UserEngagementGoalUnit',
        NAMESPACE_PREFIX + 'UserEngagementGoalUnitType__c' => 'UserEngagementGoalUnitType'
    };

    private static Map<String, String> AD_ORDER_ITEM_FIELD_MAP = new Map<String, String> {
        'Name' => 'Name',
        NAMESPACE_PREFIX + 'IsAdBleedEnabled__c' => 'IsAdBleedEnabled',
        NAMESPACE_PREFIX + 'AdBleedAmount__c' => 'AdBleedAmount',
        NAMESPACE_PREFIX + 'AdBleedAmountUom__c' => 'AdBleedAmountUom',
        NAMESPACE_PREFIX + 'AdCreativeSizeTypes__c' => 'AdCreativeSizeTypes',
        NAMESPACE_PREFIX + 'AdCreativeUrl__c' => 'AdCreativeUrl',
        NAMESPACE_PREFIX + 'AdPlacementPriorityType__c' => 'AdPlacementPriorityType',
        NAMESPACE_PREFIX + 'AdRequestedEndDate__c' => 'AdRequestedEndDate',
        NAMESPACE_PREFIX + 'AdRequestedStartDate__c' => 'AdRequestedStartDate',
        NAMESPACE_PREFIX + 'AdServerOrderIdentifier__c' => 'AdServerOrderIdentifier',
        NAMESPACE_PREFIX + 'AdServerOrderLineIdentiifier__c' => 'AdServerOrderLineIdentifier',
        NAMESPACE_PREFIX + 'AdSpaceSpecificationId__r.' + CORE_ID_FIELD_NAME => 'AdSpaceSpecificationId',
        NAMESPACE_PREFIX + 'AdTimePerEpisode__c' => 'AdTimePerEpisode',
        NAMESPACE_PREFIX + 'BonusAdTime__c' => 'BonusAdTime',
        NAMESPACE_PREFIX + 'CostPerRatingPoint__c' => 'CostPerRatingPoint',
        NAMESPACE_PREFIX + 'CustomerDayPart__c' => 'CustomerDayPart',
        NAMESPACE_PREFIX + 'GrossRatingPoint__c' => 'GrossRatingPoint',
        NAMESPACE_PREFIX + 'ImpliedRate__c' => 'ImpliedRate',
        NAMESPACE_PREFIX + 'ImpliedTotal__c' => 'ImpliedTotal',
        NAMESPACE_PREFIX + 'MaximumFrequency__c' => 'MaximumFrequency',
        NAMESPACE_PREFIX + 'MaximumFrequencyInterval__c' => 'MaximumFrequencyInterval',
        NAMESPACE_PREFIX + 'MaximumUserFrequency__c' => 'MaximumUserFrequency',
        NAMESPACE_PREFIX + 'MaximumUserFrequencyInterval__c' =>  'MaximumUserFrequencyInterval',
        NAMESPACE_PREFIX + 'MediaType__c' => 'MediaType',
        NAMESPACE_PREFIX + 'OrderId__c' => 'OrderId',
        NAMESPACE_PREFIX + 'OrderItemId__c' => 'OrderItemId',
        NAMESPACE_PREFIX + 'PaidAdTime__c' => 'PaidAdTime',
        NAMESPACE_PREFIX + 'QuoteLineItemId__c' => 'QuoteLineItemId',
        NAMESPACE_PREFIX + 'SponsorshipType__c' => 'SponsorshipType',
        NAMESPACE_PREFIX + 'TargetingParameters__c' => 'TargetingParameters',
        NAMESPACE_PREFIX + 'TotalAdTime__c' => 'TotalAdTime',
        NAMESPACE_PREFIX + 'UserEngagementGoalType__c' => 'UserEngagementGoalType',
        NAMESPACE_PREFIX + 'UserEngagementGoalUnit__c' => 'UserEngagementGoalUnit',
        NAMESPACE_PREFIX + 'UserEngagementGoalUnitType__c' => 'UserEngagementGoalUnitType'

    };
    
    public static List<String> getObjectNamesInOrderOfMigration(Boolean isAdminOnject) {
        return ( isAdminOnject ? MIGRATION_ORDER_ADMIN : MIGRATION_ORDER_NON_ADMIN);
    }

    public static String getOldObjectName(String newObjectName) {
        return NEW2OLD_OBJECT_NAME_MAP.get(newObjectName);
    }

    public static Map<String, String> getFieldMapper(String objectName) {
        switch on objectName {
            when 'AdServer' {
                return new Map<String, String>(AD_SERVER_FIELD_MAP);
            }
            when 'AdCreativeSizeType' {
                return new Map<String, String>(AD_CREATIVE_SIZE_TYPE_FIELD_MAP);
            }
            when 'MediaChannel' {
                return new Map<String, String>(MEDIA_CHANNEL_FIELD_MAP);
            }
            when 'MediaContentTitle' {
                return new Map<String, String>(MEDIA_CONTENT_TITLE_FIELD_MAP);
            }
            when 'AdServerAccount' {
                return new Map<String, String>(AD_SERVER_ACCOUNT_FIELD_MAP);
            }
            when 'AdServerUser' {
                return new Map<String, String>(AD_SERVER_USER_FIELD_MAP);
            }
            when 'AdSpaceSpecification' {
                return new Map<String, String>(AD_SPACE_SPECIFICATION_FIELD_MAP);
            }
            when 'AdSpaceCreativeSizeType' {
                return new Map<String, String>(AD_SPACE_CREATIVE_SIZE_TYPE_FIELD_MAP);
            }
            when 'AdSpaceGroupMember' {
                return new Map<String, String>(AD_SPACE_GROUP_MEMBER_FIELD_MAP);
            }
            when 'AdQuote' {
                return new Map<String, String>(AD_QUOTE_FIELD_MAP);
            }
            when 'AdQuoteLine' {
                return new Map<String, String>(AD_QUOTE_LINE_FIELD_MAP);
            }
            when 'AdOrderItem' {
                return new Map<String, String>(AD_ORDER_ITEM_FIELD_MAP);
            }
        }
        System.debug(LoggingLevel.DEBUG,'Invalid ObjectName: ' + objectName);
        return null;
    }
}