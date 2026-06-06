/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-05-2026
 * @last modified by  : Santiago Endre
**/
public with sharing class LeadTriggerHandler {

    public static void processRecords() {
        if (Trigger.isBefore) {
            Map<String,Country__c> countriesByCode = new Map<String,Country__c>();
            for (Country__c c : [SELECT Alpha_2_Code__c, Capital__c, Region__c FROM Country__c]) {
                countriesByCode.put(c.Alpha_2_Code__c, c);
            }

            for (Lead l : (List<Lead>)Trigger.new) {
                String countryCode = l.CountryCode;
                if (Trigger.isInsert || Trigger.isUpdate) {
                    if (countryCode != null && countriesByCode.containsKey(countryCode)) {
                        Country__c c = countriesByCode.get(countryCode);
                        l.Country_Capital__c = c.Capital__c;
                        l.Country_Region__c = c.Region__c;
                    }
                }
            }
        }
    }
}