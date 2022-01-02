@isTest
public class MRDTGetTimeZoneInfoTestClass{

static testMethod void validateMRDTGetTimeZoneInfo() {

operatinghours oh = new operatinghours(name='test',timezone='Antarctica/McMurdo');
insert oh;
serviceterritory st = new serviceterritory(name='test',isactive=true,operatinghoursid=oh.id);
insert st;

MRDTGetSTMs.inPayLoad payload1 = new MRDTGetSTMs.inPayLoad();

list<string> inputList = new list<string>{st.id};

list<MRDTGetTimeZoneInfo.payLoadOut> payLoadOutList = MRDTGetTimeZoneInfo.MRDTGetTimeZoneInfo(inputList);

}

}