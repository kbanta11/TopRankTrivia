import sys
import pandas as pd
from PyQt5.QtWidgets import QApplication, QLabel, QMainWindow, QToolBar, QAction, QLineEdit, QVBoxLayout, QWidget, QHBoxLayout, QPushButton, QFileDialog
from PyQt5.QtCore import Qt
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

pd.set_option('display.max_columns', None)
cred = credentials.Certificate('trivia-game-d1e6e-firebase-adminsdk-f1czf-6bfce2b44e.json')
firebase_admin.initialize_app(cred)
db = firestore.client()
# Subclass QMainWindow to customise your application's main window
class MainWindow(QMainWindow):

	def __init__(self, *args, **kwargs):
		super(MainWindow, self).__init__(*args, **kwargs)
		
		self.setWindowTitle("My Awesome App")
		
		label = QLabel("THIS IS AWESOME!!!")
		label.setAlignment(Qt.AlignCenter)
		
		self.main = MainQuestionWidget()
		self.setCentralWidget(self.main)
		
		toolbar = QToolBar("My main toolbar")
		self.addToolBar(toolbar)
		
		button_action = QAction("Start Verification", self)
		button_action.setStatusTip("This is your button")
		button_action.triggered.connect(self.getQuestionDF)
		upload_action = QAction('Upload File', self)
		upload_action.triggered.connect(self.uploadFileToFirebase)
		toolbar.addAction(button_action)
		toolbar.addAction(upload_action)

		
		
	def onMyToolBarButtonClick(self, s):
		print("click", s)

	def getQuestionDF(self, s):
		print(self.main.df.head())
		self.main.getQuestionDF(self)

		self.main.update()
		self.update()

	def uploadFileToFirebase(self, s):
		q_file = QFileDialog.getOpenFileName(self, 'Open file', '.')
		df = pd.read_csv(q_file[0])
		batch = db.batch()
		num_added = 0
		for index, row in df.iterrows():
			add_question = True
			existing_question = db.collection('questions').where('question', '==', row['Question']).stream()
			for doc in existing_question:
				add_question = False
				print('Question already exists ({}): {}'.format(row['Question'], doc.to_dict()))

			data = {
				"category": row['Category'],
				"type": "multiple",
				"difficulty": "medium",
				"question": row['Question'],
				"correct_answer": row['Correct_Answer'],
				"incorrect_answers": [row['Incorrect_Answer1'], row['Incorrect_Answer2'], row['Incorrect_Answer3']],
				"is_verified": row['Verified']
			}
			
			if(add_question):
				q_ref = db.collection('questions').document()
				batch.set(q_ref, data)
				num_added += 1

		print('Adding {} questions to database'.format(num_added))
		batch.commit()



class MainQuestionWidget(QWidget):
	df = pd.read_csv('question_files/TriviaQuestions_Chhuch.csv')
	df.reset_index()
	def __init__(self, *args, **kwargs):
		super(MainQuestionWidget, self).__init__(*args, **kwargs)
		self.column = QVBoxLayout()

		self.questionCountRow = QHBoxLayout()
		self.questionCountRow.addWidget(QLabel('# Unverified Questions: '))
		self.questionCount = QLabel()
		self.questionCountRow.addWidget(self.questionCount)
		self.questionCountWidget = QWidget()
		self.questionCountWidget.setLayout(self.questionCountRow)

		self.categoryRow = QHBoxLayout()
		self.categoryRow.addWidget(QLabel('Category: '))
		self.categoryEdit = QLineEdit(self)
		self.categoryRow.addWidget(self.categoryEdit)
		self.categoryWidget = QWidget()
		self.categoryWidget.setLayout(self.categoryRow)

		self.questionLabel = QLabel('Question:')
		self.questionEdit = QLineEdit(self)
		self.correctLabel = QLabel('Correct Answer:')
		self.correctEdit = QLineEdit(self)
		self.incorrectLabel = QLabel('Incorrect Answers')

		# First incorrect answer row
		self.incorrectRow1 = QWidget()
		self.incorrectLayout1 = QHBoxLayout()
		self.incorrectLayout1.addWidget(QLabel('1: '))
		self.incorrectEdit1 = QLineEdit()
		self.incorrectLayout1.addWidget(self.incorrectEdit1)
		self.incorrectRow1.setLayout(self.incorrectLayout1)

		# Second incorrect answer row
		self.incorrectRow2 = QWidget()
		self.incorrectLayout2 = QHBoxLayout()
		self.incorrectLayout2.addWidget(QLabel('2: '))
		self.incorrectEdit2 = QLineEdit()
		self.incorrectLayout2.addWidget(self.incorrectEdit2)
		self.incorrectRow2.setLayout(self.incorrectLayout2)

		# Third incorrect answer row
		self.incorrectRow3 = QWidget()
		self.incorrectLayout3 = QHBoxLayout()
		self.incorrectLayout3.addWidget(QLabel('3: '))
		self.incorrectEdit3 = QLineEdit()
		self.incorrectLayout3.addWidget(self.incorrectEdit3)
		self.incorrectRow3.setLayout(self.incorrectLayout3)

		#Button Row
		self.buttonWidget = QWidget()
		self.buttonLayout = QHBoxLayout()
		self.saveButton = QPushButton('Save File', self)
		self.saveButton.clicked.connect(self.saveFile)
		self.deleteButton = QPushButton('Delete Question', self)
		self.deleteButton.clicked.connect(self.deleteQuestion)
		self.verifyButton = QPushButton('Verify Question', self)
		self.verifyButton.clicked.connect(self.verifyQuestion)
		self.buttonLayout.addWidget(self.saveButton)
		self.buttonLayout.addWidget(self.deleteButton)
		self.buttonLayout.addWidget(self.verifyButton)
		self.buttonWidget.setLayout(self.buttonLayout)

		self.column.addWidget(self.questionCountWidget)
		self.column.addWidget(self.categoryWidget)		
		self.column.addWidget(self.questionLabel)
		self.column.addWidget(self.questionEdit)
		self.column.addWidget(self.correctLabel)
		self.column.addWidget(self.correctEdit)
		self.column.addWidget(self.incorrectRow1)
		self.column.addWidget(self.incorrectRow2)
		self.column.addWidget(self.incorrectRow3)
		self.column.addWidget(self.buttonWidget)
		self.setLayout(self.column)

	def verifyQuestion(self):
		self.newRow = {
			"Category": self.categoryEdit.text(),
			"Difficulty": "Medium",
			"Question": self.questionEdit.text(),
			"Correct_Answer": self.correctEdit.text(),
			"Incorrect_Answer1": self.incorrectEdit1.text(),
			"Incorrect_Answer2": self.incorrectEdit2.text(),
			"Incorrect_Answer3": self.incorrectEdit3.text(),
			"Verified": True
		}
		# print('New Row: {}'.format(self.newRow))
		# print(self.df.loc[self.currentQuestionIndex])
		#print(self.newRow.values())
		self.df.loc[self.currentQuestionIndex, 'Category'] = self.newRow['Category']
		self.df.loc[self.currentQuestionIndex, 'Difficulty'] = self.newRow['Difficulty']
		self.df.loc[self.currentQuestionIndex, 'Question'] = self.newRow['Question']
		self.df.loc[self.currentQuestionIndex, 'Correct_Answer'] = self.newRow['Correct_Answer']
		self.df.loc[self.currentQuestionIndex, 'Incorrect_Answer1'] = self.newRow['Incorrect_Answer1']
		self.df.loc[self.currentQuestionIndex, 'Incorrect_Answer2'] = self.newRow['Incorrect_Answer2']
		self.df.loc[self.currentQuestionIndex, 'Incorrect_Answer3'] = self.newRow['Incorrect_Answer3']
		self.df.loc[self.currentQuestionIndex, 'Verified'] = self.newRow['Verified']
		self.getQuestionDF(self)

	def deleteQuestion(self):
		self.df = self.df.drop([self.currentQuestionIndex])
		self.getQuestionDF(self)

	def saveFile(self):
		self.df.to_csv('question_files/TriviaQuestions_Chhuch.csv', index=False)

	def getQuestionDF(self, s):
		print(self.df.head())
		self.unverifiedDf = self.df[self.df['Verified'] != True]
		if(self.unverifiedDf.shape[0] == 0):
			self.saveFile()
			print('Saving file before crash')
		self.questionCount.setText('{}'.format(self.unverifiedDf.shape[0]))
		self.row = self.unverifiedDf.iloc[0]
		self.currentQuestionIndex = self.df[self.df['Question'] == self.row['Question']].index[0]
		print(self.row)
		# print(self.currentQuestionIndex)
		self.categoryEdit.setText(str(self.row['Category']))

		self.questionEdit.setText(self.row['Question'])
		self.correctEdit.setText(str(self.row['Correct_Answer']))

		# First incorrect answer row
		self.incorrectEdit1.setText(str(self.row['Incorrect_Answer1']))

		# Second incorrect answer row
		self.incorrectEdit2.setText(str(self.row['Incorrect_Answer2']))

		# Third incorrect answer row
		self.incorrectEdit3.setText(str(self.row['Incorrect_Answer3']))

		self.update()

app = QApplication(sys.argv)

window = MainWindow()
window.show()

app.exec_()