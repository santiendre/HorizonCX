/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-04-2026
 * @last modified by  : Santiago Endre
**/
public with sharing class SyncCountriesSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new SyncCountriesQueueable());
    }
}