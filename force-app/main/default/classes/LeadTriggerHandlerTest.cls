/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-05-2026
 * @last modified by  : Santiago Endre
**/
@isTest
public with sharing class LeadTriggerHandlerTest {

    @testSetup
    public static void makeData() {
        Country__c c1 = new Country__c(Name = 'Spain', 
                                        Alpha_2_Code__c = 'ES', 
                                        Alpha_3_Code__c = 'ESP', 
                                        Capital__c = 'Madrid', 
                                        Region__c = 'Europe');
        insert c1;
        Country__c c2 = new Country__c(Name = 'Argentina', 
                                        Alpha_2_Code__c = 'AR', 
                                        Alpha_3_Code__c = 'ARG', 
                                        Capital__c = 'Buenos Aires', 
                                        Region__c = 'Americas');
        insert c2;
        Lead l = new Lead(LastName = 'Test', 
                            Company = 'TestCo', 
                            Country = 'Spain', 
                            CountryCode = 'ES');
        insert l;
    }

    @isTest
    public static void processRecordsBeforeInsertTest() {
        Lead l = [SELECT Country_Capital__c, Country_Region__c FROM Lead WHERE LastName = 'Test' LIMIT 1];
        Assert.areEqual('Madrid', l.Country_Capital__c);
        Assert.areEqual('Europe', l.Country_Region__c);
    }

    @isTest
    public static void processRecordsBeforeUpdateTest() {
        Lead l = [SELECT Country_Capital__c, Country_Region__c FROM Lead WHERE LastName = 'Test' LIMIT 1];
        l.Country = 'Argentina';
        l.CountryCode = 'AR';
        update l;
        l = [SELECT Country_Capital__c, Country_Region__c FROM Lead WHERE LastName = 'Test' LIMIT 1];
        Assert.areEqual('Buenos Aires', l.Country_Capital__c);
        Assert.areEqual('Americas', l.Country_Region__c);
    }
}