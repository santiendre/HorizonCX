/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-06-2026
 * @last modified by  : Santiago Endre
**/
@isTest
public with sharing class LeadTriggerHandlerTest {

    @testSetup
    public static void makeData() {
        Profile standard = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile contractManager = [SELECT Id FROM Profile WHERE Name = 'Contract Manager' LIMIT 1];

        User stdUser = new User(
            LastName = 'TestStd',
            Email = 'teststd@test.com',
            Username = 'teststd@test.com.sendre',
            Alias = 'teststd',
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standard.Id
        );
        insert stdUser;

        User cmUser = new User(
            LastName = 'TestCM',
            Email = 'testcm@test.com',
            Username = 'testcm@test.com.sendre',
            Alias = 'testcm',
            TimeZoneSidKey = 'Europe/Madrid',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = contractManager.Id
        );
        insert cmUser;

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

        Lead l = new Lead(LastName = 'TestLead', 
                            Company = 'TestCompany', 
                            Country = 'Spain', 
                            CountryCode = 'ES');
        insert l;
    }

    @isTest
    public static void processRecordsBeforeInsertTest() {
        Lead l = [SELECT Country_Capital__c, Country_Region__c FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        Assert.areEqual('Madrid', l.Country_Capital__c);
        Assert.areEqual('Europe', l.Country_Region__c);
    }

    @isTest
    public static void processRecordsBeforeUpdateTest() {
        Lead l = [SELECT Country_Capital__c, Country_Region__c FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        l.Country = 'Argentina';
        l.CountryCode = 'AR';
        update l;
        l = [SELECT Country_Capital__c, Country_Region__c FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        Assert.areEqual('Buenos Aires', l.Country_Capital__c);
        Assert.areEqual('Americas', l.Country_Region__c);
    }

    @isTest
    public static void processRecordsCountryNotFoundTest() {
        Lead l = [SELECT CountryCode FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        l.CountryCode = 'US';
        update l;
        l = [SELECT Country_Capital__c, Country_Region__c FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        Assert.isNull(l.Country_Capital__c);
        Assert.isNull(l.Country_Region__c);
    }

    @isTest
    public static void changeOwnerStdUserTest() {
        Lead l = [SELECT LeadSource, NumberOfEmployees, Country FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        User stdUser = [SELECT Id FROM User WHERE LastName = 'TestStd' LIMIT 1];
        String vrMessage = 'Country, Lead Source and No. of Employees are mandatory for Owner changes';
        System.runAs(stdUser) {
            //Missing No of employees
            try {
                l.LeadSource = 'Web';
                l.NumberOfEmployees = null;
                l.Country = 'Spain';
                l.OwnerId = stdUser.Id;
                update l;
            } catch(Exception e) {
                Assert.isTrue(e.getMessage().contains(vrMessage));
            }
            //Missing LeadSource
            try {
                l.LeadSource = null;
                l.NumberOfEmployees = 10;
                l.Country = 'Spain';
                l.OwnerId = stdUser.Id;
                update l;
            } catch(Exception e) {
                Assert.isTrue(e.getMessage().contains(vrMessage));
            }
            //Missing Country
            try {
                l.LeadSource = 'Web';
                l.NumberOfEmployees = 10;
                l.Country = null;
                l.OwnerId = stdUser.Id;
                update l;
            } catch(Exception e) {
                Assert.isTrue(e.getMessage().contains(vrMessage));
            }
            //Success
            l.LeadSource = 'Web';
            l.NumberOfEmployees = 10;
            l.Country = 'Spain';
            l.OwnerId = stdUser.Id;
            update l;
            l = [SELECT OwnerId FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
            Assert.areEqual(stdUser.Id, l.OwnerId);
        }
    }

    @isTest
    public static void changeOwnerCMUserTest() {
        Lead l = [SELECT LeadSource, NumberOfEmployees, Country FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        User cmUser = [SELECT Id FROM User WHERE LastName = 'TestCM' LIMIT 1];
        String vrMessage = 'Country, Lead Source and No. of Employees are mandatory for Owner changes';
        System.runAs(cmUser) {
            //Missing LeadSource
            try {
                l.LeadSource = null;
                l.NumberOfEmployees = null;
                l.Country = 'Spain';
                l.OwnerId = cmUser.Id;
                update l;
            } catch(Exception e) {
                Assert.isTrue(e.getMessage().contains(vrMessage));
            }
            //Missing Country
            try {
                l.LeadSource = 'Web';
                l.NumberOfEmployees = null;
                l.Country = null;
                l.OwnerId = cmUser.Id;
                update l;
            } catch(Exception e) {
                Assert.isTrue(e.getMessage().contains(vrMessage));
            }
            //Success
            l.LeadSource = 'Web';
            l.NumberOfEmployees = null;
            l.Country = 'Spain';
            l.OwnerId = cmUser.Id;
            update l;
            l = [SELECT OwnerId FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
            Assert.areEqual(cmUser.Id, l.OwnerId);
        }
    }

    @isTest
    public static void changeOwnerSysAdminTest() {
        Lead l = [SELECT LeadSource, NumberOfEmployees, Country FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        User cmUser = [SELECT Id FROM User WHERE LastName = 'TestCM' LIMIT 1];
        String vrMessage = 'Country, Lead Source and No. of Employees are mandatory for Owner changes';
        //Missing LeadSource
        try {
            l.LeadSource = null;
            l.NumberOfEmployees = null;
            l.Country = null;
            l.OwnerId = cmUser.Id;
            update l;
        } catch(Exception e) {
            Assert.isTrue(e.getMessage().contains(vrMessage));
        }
        //Success
        l.LeadSource = 'Web';
        l.NumberOfEmployees = null;
        l.Country = null;
        l.OwnerId = cmUser.Id;
        update l;
        Assert.areEqual(cmUser.Id, l.OwnerId);
    }

    @isTest
    public static void ownerChangeTimestampTest() {
        Lead l = [SELECT LeadSource, Owner_Since__c FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        Datetime oldTimeStamp = l.Owner_Since__c;
        User cmUser = [SELECT Id FROM User WHERE LastName = 'TestCM' LIMIT 1];
        l.LeadSource = 'Web';
        l.OwnerId = cmUser.Id;
        update l;
        l = [SELECT Owner_Since__c FROM Lead WHERE LastName = 'TestLead' LIMIT 1];
        Assert.areNotEqual(oldTimeStamp, l.Owner_Since__c);
    }
}