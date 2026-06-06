/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-06-2026
 * @last modified by  : Santiago Endre
**/
@isTest
public with sharing class SyncCountriesTest {

    @isTest
    public static void calloutSuccessTest() {
        Test.setMock(HttpCalloutMock.class, new SyncCountriesCalloutMock(200));
        Test.startTest();
        System.enqueueJob(new SyncCountriesQueueable());
        Test.stopTest();
        Country__c c = [SELECT Name, Alpha_2_Code__c, Alpha_3_Code__c, Capital__c, Region__c, Regional_Blocs__c FROM Country__c WHERE Alpha_2_Code__c = 'ES' LIMIT 1];
        Assert.areEqual('Spain', c.Name);
        Assert.areEqual('ESP', c.Alpha_3_Code__c);
        Assert.areEqual('Madrid', c.Capital__c);
        Assert.areEqual('Europe', c.Region__c);
        Assert.areEqual('EU; EEA', c.Regional_Blocs__c);
        Assert.areEqual(2, [SELECT Id FROM Country__c].size());
    }

    @isTest
    public static void calloutErrorTest() {
        Test.setMock(HttpCalloutMock.class, new SyncCountriesCalloutMock(401));
        Test.startTest();
        System.enqueueJob(new SyncCountriesQueueable());
        Test.stopTest();
        Assert.areEqual(0, [SELECT Id FROM Country__c].size());
    }

    @isTest
    public static void scheduleTest() {
        String CRON_EXP = '0 0 0 * * ?';
		Test.startTest();
      	String jobId = System.schedule('SyncCountriesTest', CRON_EXP, new SyncCountriesSchedule());
		Test.stopTest();   
		CronTrigger ct = [SELECT CronExpression, TimesTriggered FROM CronTrigger WHERE id = :jobId];
        Assert.areEqual('0 0 0 * * ?', ct.CronExpression);
        Assert.areEqual(0, ct.TimesTriggered);
    }
}