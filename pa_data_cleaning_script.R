library(readr)
-------
# This script scrapes through organisation-wide Registration data and collects values for each feature of interest
# User, Mentor and Mentee data sources are then anonymized according to GDPR guidelines
# All 4 processed data sources are then merged into two data sets (mentorUserDataConsol and menteeUserDataConsol)
# The output data are then used for dashboarding and analytics
-------
  
# Import Registration Data
regData <- read_csv("Registration_Data.csv")

# Collect values for type of degrees
regDeg <- regData[which(regData$question=="What degree are you currently studying for?"),-c(2,4)]
colnames(regDeg)[colnames(regDeg)=="value"] <- "degree"

# Collect values for graduation year
regGrad <- regData[which(regData$question=="351. In what year will you be graduating?" | regData$question=="51. What year will you be graduating (did you graduate)?" | regData$question=="105. + 139. If you start university that year, what year will you be graduating? 2019-02-20T11:53:08.006Z" | regData$question=="105. If you start university that year, what year will you be graduating?" | regData$question=="139. If you start university that year, what year will you be graduating?"),-c(2,4)]
colnames(regGrad)[colnames(regGrad)=="value"] <- "grad_year"

# Collect values for whether they are from largest 3 cities
reg3LargeCities <- regData[which(regData$question=="171. Are you from one of the three largest cities in your country?"),-c(2,4)]
colnames(reg3LargeCities)[colnames(reg3LargeCities)=="value"] <- "from_large_city"

# Collect values for parent educational background
regParentDeg <- regData[which(regData$question=="175. Did either of your parents obtain a Bachelor's degree or equivalent?"),-c(2,4)]
colnames(regParentDeg)[colnames(regParentDeg)=="value"] <- "parent_have_bachelor"

# Collect values for ethnicity
regEthnic <- regData[which(regData$question=="176. What is your ethnic background?"),-c(2,4)]
colnames(regEthnic)[colnames(regEthnic)=="value"] <- "ethnic_bkg"

# Collect values for where they heard about PA -> (marketing dashboard)
regRefer <- regData[which(regData$question=="203. Who referred you to us? Because we’d like to send them a thank you ;)"),-c(2,4)]
colnames(regRefer)[colnames(regRefer)=="value"] <- "referred_from"

# Collect values for eligibilty of free school meals
regMeals <- regData[which(regData$question=="343. Are you, or have you ever been eligible to receive free school meals (pupil premium)?"),-c(2,4)]
colnames(regMeals)[colnames(regMeals)=="value"] <- "elig_sch_meals"

# Collect values for family's socioeconomic status
regFamSocio <- regData[which(regData$question=="401. How would you describe your family's socioeconomic status? Please take into consideration where you live and how many dependents there are in your household."),-c(2,4)]
colnames(regFamSocio)[colnames(regFamSocio)=="value"] <- "fam_socio"

# Merge all columns into one consolidated data frame -> regDataConsol
regMergeTemp <- merge(regDeg, regGrad, by = "id", all = TRUE)
regMergeTemp1 <- merge(regMergeTemp, reg3LargeCities, by = "id", all = TRUE)
regMergeTemp2 <- merge(regMergeTemp1, regParentDeg, by = "id", all = TRUE)
regMergeTemp3 <- merge(regMergeTemp2, regEthnic, by = "id", all = TRUE)
regMergeTemp4 <- merge(regMergeTemp3, regMeals, by = "id", all = TRUE)
regMergeTemp5 <- merge(regMergeTemp4, regFamSocio, by = "id", all = TRUE)
regDataConsol <- merge(regMergeTemp5, regRefer, by = "id", all = TRUE)

# Import User Data
userData <- read_csv("User_Data.csv")
# Remove irrelevant and personal identification columns from userData
userDataAnon <- userData[, -c(1,2,4,5,6,7,11,13,15,16,17,18,19,22,23,24,27,29,32,33,35,36,38,39,42,43,44,45)]

# Import Mentor Data
mentorData <- read_csv("Mentor_Data.csv")
# Remove columns to make data anonymous
mentorDataAnon <- mentorData[, -c(2,3,4,6,9,11)]

# Merge consolidated registration data with mentor user data
mentorDataConsol <- merge(regDataConsol, mentorDataAnon, by = "id", all.y = TRUE)
mentorUserDataConsol <- merge(mentorDataConsol, userDataAnon, by = "id", all.y = TRUE)

# Import Mentee Data
menteeData <- read_csv("Mentee_Data.csv")
# Remove columns to make data anonymous
menteeDataAnon <- menteeData[, -c(2,3,4,6,9,11)]

# Merge consolidated registration data with mentee user data
menteeDataConsol <- merge(regDataConsol, menteeDataAnon, by = "id", all.y = TRUE)
menteeUserDataConsol <- merge(menteeDataConsol, userDataAnon, by = "id", all.y = TRUE)

# Output csv file for dashboard
write_excel_csv(mentorUserDataConsol,"mentorUserDataConsol.csv")
write_excel_csv(menteeUserDataConsol,"menteeUserDataConsol.csv")

