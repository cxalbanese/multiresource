Hello World
# Service Appointment Generator Package 
Allow a user to create and assign multiple service appointments for a single work order. This package is intended to help the user create and manage multiple service appointments on a single screen. 
   - It does not use the scheduling features of Salesforce Field Service but the scheduler user can use the SFS Gantt to review and manage violations and perform scheduling actions like drag and drop, candidates, RSO, etc on these service appointments.
   - Crews are not used/supported in this package
   - Multi-day work is not used/supported in this package

## Basic Installation Notes
1. Assign permission set called MR_DT_Permission_Set to the admin users and the scheduling users who will use this package
2. Add the flow called Multi Resource Assignment Wizard to your work order lightning page and make sure to Pass record ID  into this variable is checked on the flow component.
3. Optionally use the Header and Collapsible Right Sidebar template (MR_DT_Template) for the work order page.

## V1 Changes- Dec 13, 2022
### Added new features:
1.  Technician Missing Skill Checker and Skill Matcher - this displays skills that the technian has, including those matching on skill level and those not. it also displays a summary of the skill match counts for each techncian.
2.  Work Order Missing Skill Checker - this displays a summary of the skills that are missing from the available technicians when compared to the work order required skills. It also displays a summary of the skills that are missing from the selected technicians when reviewing the generated service appointments.
3. Overlap / Availability checker - this displays a summmary of any overlaps that are encountered. It displays Resource Absences and Service Appointments that already exist for the pool of technicians and the selected technicians. It also provides a summary of availability.
4. New Fields - new fields have been added to Service Territory Member and Service Appointment to hold the overlap information
   - SkillRequirement.MR_DT_Skill_Name_and_Level__c - formula field to display skill name and level - used to display required skills on WO
   - ServiceAppointment.MR_DT_Conflict_Details__c - text field to display list of RAs/SAs in conflict with current SA date
   - ServiceAppointment.MR_DT_Percent_Availability__c - text field displaying % of availability for the tech for the current SA date
   - ServiceAppointment.MR_DT_Skill_Levels_Matched__c - text field displays ratio of skill levels matched to required, for example 3/5
   - ServiceAppointment.MR_DT_Skill_Names_Matched__c - text field displaying list of skills matched regardless whether levels match
   - ServiceAppointment.MR_DT_Skills_Matched__c - text field displaying list of skills and skill levels matched
   - ServiceTerritoryMember.MR_DT_Skill_Levels_Matched__c - text field displays ratio of skill levels matched to required, for example 3/5
   - ServiceTerritoryMember.MR_DT_Skill_Names_Matched__c - text field displaying list of skills matched regardless whether levels match
   - ServiceTerritoryMember.MR_DT_Skills_Matched__c - text field displaying list of skills and skill levels matched
   - ServiceTerritoryMember.MR_DT_Percent_Availability__c - text field displaying % of availability for the tech for the current SA date
5. Lightning Page Template with expandable main section - this template provides more room for the user.

## New Classes
1.  MRDTGetOverlapInfo - calculates whether there are existing RAs and/or SAs that overlap with the new SAs being generated
2.  MRDTSkillMatcher - calculates skill matching profile for each service resource displayed. also calculates the skills that are not present on the service resources displayed.
3.  MRDTresourceOverlaps - this is the resource overlap and skill profile. This class performs no processing, it's simply the data structure

## Miscellaneous notes
1. In the flow MR DT Service_Appointment Creator, the screen called Select_Resource has the display of a field called outputOverlapDebug. This is intended to help you inspect the results from the overlap checking.
    - Remove this field or use component visibility to hide it from the user
