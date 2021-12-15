@isTest
public class MRDTAssignmentTestClass{

static testMethod void validateMRDTAssignment() {

id usrid = UserInfo.getUserId();
worktype wt = new worktype(name='test',estimatedduration=1,durationtype='hours');
operatinghours oh = new operatinghours(name='test');
insert oh;
serviceterritory st = new serviceterritory(name='test',isactive=true,operatinghoursid=oh.id);
serviceresource sr = new serviceresource(name='test',isactive=true,relatedrecordid=usrid,resourcetype='T');
insert wt;
insert st;
insert sr;
serviceterritorymember stm = new serviceterritorymember (serviceresourceid=sr.id,serviceterritoryid = st.id,effectivestartdate = datetime.now());
insert stm;

workorder wo = new workorder();
wo.worktypeid = wt.id;
wo.serviceterritoryid = st.id;
insert wo;
serviceappointment sa = new serviceappointment(
mr_service_resource__c = sr.id,parentrecordid=wo.id,earlieststarttime=datetime.now(),duedate=datetime.now().adddays(7),schedstarttime=datetime.now(),schedendtime=datetime.now().addhours(1));
list<serviceappointment> listsa = new list<serviceappointment> {sa};
list<list<serviceappointment>> listlistsa = new list<list<serviceappointment>>{listsa};

list<string> results = MRDTAssignment.MRDTAssignment(listlistsa);


}



}