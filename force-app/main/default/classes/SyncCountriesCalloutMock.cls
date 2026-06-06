/**
 * @description       : 
 * @author            : Santiago Endre
 * @group             : 
 * @last modified on  : 06-06-2026
 * @last modified by  : Santiago Endre
**/
@isTest
public with sharing class SyncCountriesCalloutMock implements HttpCalloutMock {

    private Integer statusCode;

    public SyncCountriesCalloutMock(Integer statusCode) {
        this.statusCode = statusCode;
    }
    
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        if (statusCode == 200) {
            res.setBody('[{"name":"Spain","alpha2Code":"ES","alpha3Code":"ESP","capital":"Madrid","region":"Europe","regionalBlocs":[{"acronym":"EU","name":"European Union"},{"acronym":"EEA","name":"European Economic Area"}]},{"name":"Argentina","alpha2Code":"AR","alpha3Code":"ARG","capital":"Buenos Aires","region":"Americas","regionalBlocs":[{"acronym":"MERCOSUR","name":"Southern Common Market"},{"acronym":"USAN","name":"Union of South American Nations"}]}]');
        } else if (statusCode == 401) {
            res.setBody('{"error":{"code":"101","message":"invalid_access_key - No API Key was specified or an invalid API Key was specified."}}');
        } else if (statusCode == 429) {
            res.setBody('{"error":{"code":"usage_limit_reached","message":"Your monthly usage limit has been reached. Please upgrade your Subscription Plan."}}');
        }
        return res;
    }
}