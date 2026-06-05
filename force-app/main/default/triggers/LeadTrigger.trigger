/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-05-2026
 * @last modified by  : Santiago Endre
**/
trigger LeadTrigger on Lead (before insert, before update) {
    LeadTriggerHandler.processRecords();
}