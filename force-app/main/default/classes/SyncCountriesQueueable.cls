/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-06-2026
 * @last modified by  : Santiago Endre
**/
public with sharing class SyncCountriesQueueable implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext QC) {
        External_API_Configuration__mdt config = External_API_Configuration__mdt.getAll().get('CountryLayer');
        String auth = 'access_key=' + config.API_Key__c;
        String filter = 'fields=name;alpha2Code;alpha3Code;capital;region;regionalBlocs';
        String path = config.Endpoint__c + '?' + auth + '&' + filter;
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(path);
        req.setMethod('GET');
        req.setTimeout(120000);
        try {
            HttpResponse res = http.send(req);
            Integer statusCode = res.getStatusCode();
            if (statusCode == 200) {
                List<CountryWrapper> wrapperList = (List<CountryWrapper>)JSON.deserialize(res.getBody(), List<CountryWrapper>.class);
                List<Country__c> countries = new List<Country__c>();
                for (CountryWrapper cw : wrapperList) {
                    String regionalBlocs = '';
                    if (cw.regionalBlocs != null) {
                        for (RegionalBloc rb : cw.regionalBlocs) {
                            if (!String.isBlank(regionalBlocs)) {
                                regionalBlocs += '; ';
                            }
                            regionalBlocs += rb.acronym;
                        }
                    }
                    countries.add(new Country__c(Name = cw.name, 
                                                Alpha_2_Code__c = cw.alpha2Code, 
                                                Alpha_3_Code__c = cw.alpha3Code, 
                                                Capital__c = cw.capital,
                                                Region__c = cw.region,
                                                Regional_Blocs__c = regionalBlocs));
                }
                Database.upsert(countries, Country__c.Alpha_2_Code__c, false);
            } else if (statusCode == 401 || statusCode == 429) {
                System.debug(statusCode);
                System.debug(res.getBody());
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{config.Notification_Email__c});
                mail.setSubject('Country Sync Error - ' + res.getStatusCode());
                mail.setPlainTextBody('The country sync job failed with status ' + res.getStatusCode() + ': ' + res.getBody());
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            } else {
                System.debug(statusCode);
                System.debug(res.getBody());
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public class RegionalBloc {
        String acronym;
        String name;
    }

    public class CountryWrapper {
        String name;
        String alpha2Code;
        String alpha3Code;
        String capital;
        String region;
        List<RegionalBloc> regionalBlocs;
    }
}