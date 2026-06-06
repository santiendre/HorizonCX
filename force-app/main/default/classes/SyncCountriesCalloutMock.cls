/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-05-2026
 * @last modified by  : Santiago Endre
**/
@isTest
public with sharing class SyncCountriesCalloutMock implements HttpCalloutMock {
    
    public HttpResponse respond(HttpRequest req) {
        String body = '[{"name":"Spain","alpha2Code":"ES","alpha3Code":"ESP","capital":"Madrid","region":"Europe","regionalBlocs":[{"acronym":"EU","name":"European Union"},{"acronym":"EEA","name":"European Economic Area"}]},{"name":"Argentina","alpha2Code":"AR","alpha3Code":"ARG","capital":"Buenos Aires","region":"Americas","regionalBlocs":[{"acronym":"MERCOSUR","name":"Southern Common Market"},{"acronym":"USAN","name":"Union of South American Nations"}]}]';
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody(body);
        return res;
    }
}
