User adminUser = [SELECT Email, TimeZoneSidKey, LanguageLocaleKey FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name='System Administrator') LIMIT 1];
final String timezone = adminUser.TimeZoneSidKey;
final String locale = adminUser.LanguageLocaleKey;
final String actualEmail = adminUser.Email;
final String fn = 'Santa Agent';
final String ln = 'User ';
final String alias = (fn.replaceAll('[ ]', '_').toLowerCase().substring(0, 1) + ln.replaceAll('[ ]', '_').toLowerCase()).substring(0,4) + String.valueOf(DateTime.now().getTime()).reverse().substring(0,4);
final String email = UserInfo.getOrganizationId() + '.' + fn.replaceAll('[ ]', '_').toLowerCase() + '.' + ln.replaceAll('[ ]', '_').toLowerCase() + '@example.com';

// get einstein agent user
final Profile p = [SELECT Id FROM Profile WHERE Name='Einstein Agent User' LIMIT 1];

// get permission sets, permission set groups and permission set licenses required
final List<PermissionSetLicense> permissionSetLicenses = [SELECT Id FROM PermissionSetLicense WHERE DeveloperName IN ('EinsteinGPTPromptTemplatesPsl', 'GenieDataPlatformStarterPsl', 'AgentforceServiceAgentUserPsl')];
final List<PermissionSetGroup> permissionSetGroups = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName in ('AgentforceServiceAgentUserPsg')];
final List<PermissionSet> permissionSets = [SELECT Id FROM PermissionSet WHERE Type='Standard' AND PermissionsetGroupId=null AND Name='AgentforceServiceAgentBase'];

// create user
User u = new User();
u.firstname = fn;
u.lastname = ln;
u.username = email;
u.email = actualEmail;
u.ProfileId = p.Id;
u.alias = alias;
u.EmailEncodingKey = 'UTF-8';
u.IsActive = true;
u.LanguageLocaleKey = 'en_US';
u.LocaleSidKey = locale;
u.TimeZoneSidKey = timezone;
insert u;

// assign permission sets, permission set groups and permission set licens
final List<SObject> psas = new List<SObject>();
for (PermissionSet ps : permissionSets) {
    psas.Add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id));
}
for (PermissionSetGroup psg : permissionSetGroups) {
    psas.Add(new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId = u.Id));
}
/*
// NOTE: Apparently the PermissionSetLicenses are automatically added
for (PermissionSetLicense psl : permissionSetLicenses) {
    psas.Add(new PermissionSetLicenseAssign(PermissionSetLicenseId = psl.Id, AssigneeId = u.Id));
}
*/
insert psas;
