import xlrd
import xlwt
pastYear = xlrd.open_workbook("email_pastyear.xlsx")
thisYear = xlrd.open_workbook("email_thisyear.xlsx")

def retrieve_email(data):
	table = data.sheet_by_index(0)
	return table.col_values(4)

def retrieve_adress(email):
	email = email[email.find('(')+1 : email.find(')')]
	return email





# retrieve the past year email and store in pastYear_list
pastYear_list = retrieve_email(pastYear)
for i in range(0,len(pastYear_list)):
	sample = retrieve_adress(pastYear_list[i])
	pastYear_list[i] = sample

# retrieve this year email and store in thieYear_list
thisYear_list = retrieve_email(thisYear)
for i in range(0,len(thisYear_list)):
	if '(' in thisYear_list[i]:
		sample = retrieve_adress(thisYear_list[i])
		thisYear_list[i] = sample


firstYear_list = []
for email in thisYear_list:
	if email not in pastYear_list:
		firstYear_list.append(email)

data = xlwt.Workbook()
table = data.add_sheet("First Year Students")
for i in range(0,len(firstYear_list)):
	table.write(i,0,firstYear_list[i])

data.save("first_year_students.xls")
print(firstYear_list)


string = ""
for element in firstYear_list:
	element = element[0:len(element)]
	string += (element + '; ')

print(string)
file = open("email_address",'w')
file.write(string)
file.close()






