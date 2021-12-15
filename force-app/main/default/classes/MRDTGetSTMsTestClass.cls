@isTest
public class MRDTGetSTMsTestClass{

static testMethod void validateMRDTGetSTMs() {

serviceterritory st = new serviceterritory(name='test',isactive=true);
skill sk = new skill(developername='test', MasterLabel='test');

MRDTGetSTMs.inPayLoad payload = new MRDTGetSTMs.inPayLoad();

payload.inTerritoryId = 'All';
payload.inSkillId = 'All';
payload.startDate = date.today();
payload.enddate = date.today().adddays(7);
list<MRDTGetSTMs.inPayLoad> inputList = new list<MRDTGetSTMs.inPayLoad>{payload};

list<list<serviceterritorymember>> outputList = MRDTGetSTMs.GetSTMS(inputList);

MRDTGetSTMs.inPayLoad payload1 = new MRDTGetSTMs.inPayLoad();

payload1.inTerritoryId = st.id;
payload1.inSkillId = sk.id;
payload1.startDate = date.today();
payload1.enddate = date.today().adddays(7);
list<MRDTGetSTMs.inPayLoad> inputList1 = new list<MRDTGetSTMs.inPayLoad>{payload1};

list<list<serviceterritorymember>> outputList1 = MRDTGetSTMs.GetSTMS(inputList1);

}

}