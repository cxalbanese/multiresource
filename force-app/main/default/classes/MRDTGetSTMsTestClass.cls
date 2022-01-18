@isTest
public class MRDTGetSTMsTestClass{

static testMethod void validateMRDTGetSTMs() {
operatinghours oh = new operatinghours(name='test',timezone='America/Los_Angeles');
insert oh;
serviceterritory st = new serviceterritory(name='test',isactive=true,operatinghoursid=oh.id);
insert st;
skill sk = new skill(developername='test', MasterLabel='test');
Profile prof = [select id from profile where name = 'Standard User'];
User user = new User();
user.firstName = 'test1';
user.lastName = 'test2';
user.profileId = prof.id;
user.username = 'test' + math.random().format() + '@test.com';
user.email = 'test@test.com';
user.EmailEncodingKey = 'ISO-8859-1';
user.Alias = math.random().format();
user.TimeZoneSidKey = 'America/Los_Angeles';
user.LocaleSidKey = 'en_US';
user.LanguageLocaleKey = 'en_US';
insert user;
ServiceResource sr 
                        = new ServiceResource(Name='ResourceName2'
                                           , ResourceType ='T'
                                           , RelatedRecordId=user.Id
                                           , IsActive=true);
insert sr;
serviceterritorymember stm = new serviceterritorymember(serviceresourceid = sr.id,serviceterritoryid=st.id,territorytype='p', EffectiveStartDate=datetime.now().adddays(-1));
insert stm;
resourceabsence ra = new resourceabsence (resourceid=sr.id,start=datetime.now(),end=datetime.now().addhours(4));
insert ra;
MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();

payload.inTerritoryId = 'All';
payload.inSkillId = 'All';
payload.startDate = date.today();
payload.enddate = date.today().adddays(7);
list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

list<MRDTGetSTMs.outPayLoad> outputList = MRDTGetSTMs.GetSTMS(inputList);

MRDTGetSTMs.inPayLoad payload1 = new MRDTGetSTMs.inPayLoad();

payload1.inTerritoryId = st.id;
payload1.inSkillId = sk.id;
payload1.startDate = date.today();
payload1.enddate = date.today().adddays(7);
list<MRDTGetSTMs.inPayLoad> inputList1 = new list<MRDTGetSTMs.inPayLoad>{payload1};

list<MRDTGetSTMs.outPayLoad> outputList1 = MRDTGetSTMs.GetSTMS(inputList1);

}

}