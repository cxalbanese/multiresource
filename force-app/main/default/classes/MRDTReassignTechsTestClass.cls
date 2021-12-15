@isTest
public class MRDTReassignTechsTestClass{

static testMethod void validateReassignTechs() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@example.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@MRDTReassignTechs.com');
insert u;

id usrid = UserInfo.getUserId();
worktype wt = new worktype(name='test',estimatedduration=1,durationtype='hours');
operatinghours oh = new operatinghours(name='test');
insert oh;
serviceterritory st = new serviceterritory(name='test',isactive=true,operatinghoursid=oh.id);
serviceresource sr = new serviceresource(name='test',isactive=true,relatedrecordid=usrid,resourcetype='T');

serviceresource sr1 = new serviceresource(name='test1',isactive=true,relatedrecordid=u.id,resourcetype='T');
insert wt;
insert st;
insert sr;
insert sr1;
serviceterritorymember stm = new serviceterritorymember (serviceresourceid=sr.id,serviceterritoryid = st.id,effectivestartdate = datetime.now());
insert stm;
serviceterritorymember stm1 = new serviceterritorymember (serviceresourceid=sr1.id,serviceterritoryid = st.id,effectivestartdate = datetime.now());
insert stm1;
workorder wo = new workorder();
wo.worktypeid = wt.id;
wo.serviceterritoryid = st.id;
insert wo;
serviceappointment sa = new serviceappointment(
mr_service_resource__c = sr.id,parentrecordid=wo.id,earlieststarttime=datetime.now(),duedate=datetime.now().adddays(7),schedstarttime=datetime.now(),schedendtime=datetime.now().addhours(1));
insert sa;
assignedresource ar = new assignedresource(serviceresourceid = sr.id,serviceappointmentid=sa.id);
insert ar;
list<serviceappointment> listsa = new list<serviceappointment> {sa};
MRDTReassignTechs.inPayLoad inPayload = new MRDTReassignTechs.inPayLoad();
inPayload.serviceResourceId = sr1.id;
inPayload.listSA = listsa;

list<string> results = MRDTReassignTechs.ReassignTechs(new list<MRDTReassignTechs.inPayLoad>{inPayload});


}



}