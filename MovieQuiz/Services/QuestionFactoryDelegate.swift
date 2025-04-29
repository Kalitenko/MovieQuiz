protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didBeginAssemblingNextQuestion()
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
