public with sharing class AdSales236Migrator {
    public AdSales236Migrator() {

    }
    public void migrateAdminData() {
        MigrateAdSalesObjectBatch batchable = new MigrateAdSalesObjectBatch(0, true);
        Id batchId = Database.executeBatch(batchable, 200);
        List<String> objectNames = AdSalesMapper.getObjectNamesInOrderOfMigration(true);
        System.debug(LoggingLevel.DEBUG, 'Starting batch job \'' + batchId + '\' for migration of records for \'' + objectNames[0] + '\' object...');
    }
    public void migrateNonAdminData() {
        MigrateAdSalesObjectBatch batchable = new MigrateAdSalesObjectBatch(0, false);
        Id batchId = Database.executeBatch(batchable, 200);
        List<String> objectNames = AdSalesMapper.getObjectNamesInOrderOfMigration(false);
        System.debug(LoggingLevel.DEBUG, 'Starting batch job \'' + batchId + '\' for migration of records for \'' + objectNames[0] + '\' object...');
    }
}