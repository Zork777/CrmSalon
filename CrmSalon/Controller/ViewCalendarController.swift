//
//  ViewCalendar.swift
//  CrmSalon
//
//  Created by Евгений Захаров on 03.04.2022.
//

import UIKit
import CoreData

class ViewCalendarController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, UIPickerViewDataSource {

    

    var selectClientPhone: String?
    var selectClient = false
    var selectOrderForMove: Int?
    var orderForSave = OrderForSave()

    
    let fontSizeForLabelSelectMaster: CGFloat = 20
    let screenWidth = UIScreen.main.bounds.width - 32
    var screenHeight: CGFloat?
    var selectedMasterRow = 0
    var selectedServiceRow = 0

    private var mastersTable = [EntityMasters]()
    private var servicesTable = [EntityServices]()
    private let base = BaseCoreData()
    private let lineCoordinate = DrawLineCoordinate()
    private var dateForLabel = Date().stripTime()
    private var ordersTable: [Int : EntityOrders] = [:]
    private var selectCellWithOrder: [Int : CellText] = [:] //храним выделенные ячейки (ячейки в работе)
    
    
    private let idCell = "ItemCell"
    
    struct CellText {
        var clientName: String?
        var masterName: String?
        var service: String?
        var backgroundColor: UIColor
    }
    private let itemsPerRow: CGFloat = 5
    private let sectionInsets = UIEdgeInsets(
                                              top: 0.0,
                                              left: 0.0,
                                              bottom: 0.0,
                                              right: 0.0)
    
//    lazy var dateToString: DateFormatter = {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .none
//        return dateFormatter
//    }()
    

 
    @IBOutlet weak var collectionViewCalendar: ViewCalendarCollection!
    @IBOutlet weak var labelService: UILabel!
    @IBOutlet weak var labelMaster: UILabel!
    @IBOutlet weak var labelPhoneNumber: UILabel!
    @IBOutlet weak var labelFio: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var logoSalon: UIImageView!
    @IBOutlet weak var labelTitleView: UILabel!
 
    
    var saveButton: UIBarButtonItem?
    var cancelButton: UIBarButtonItem?
    var undeleteButton: UIBarButtonItem?

    
    class BarButtonDelete: UIBarButtonItem{
        var order: EntityOrders?
    }
    
//    class BarButtonEdit: UIBarButtonItem{
//        var function: (()->())? = nil
//    }
//
    @objc func buttonDeleteOrder(sender: BarButtonDelete) {
        do{
//            try base.deleteObject(object: sender.order!) // удаление навсегда ордера
            try base.deleteOrder(order: sender.order!) //помечаем что удален
            if !selectClient {selectCellWithOrder.removeAll()} //удаление всех выделенных ячеек при заходе через календарь
            reloadCell()
            animationSaveFinish(view: view, text: "Удалено")
            selectOrderForMove = nil
            if selectClient, !selectCellWithOrder.isEmpty{
                navigationItem.rightBarButtonItems = [saveButton!, cancelButton!]} //восстанавливаем кнопки т.к. остались выделенные ячейки для создания ордера
        }
        catch{
            showMessage(message: error.localizedDescription)
        }
    }
    
//    @objc func buttonEditOrder(sender: BarButtonEdit){
//        sender.function!()
//    }
    
    @objc func funcButtonSaveOrder() {
        orderSave()
        selectCellWithOrder.removeAll() //снимаем выделения со всех ячеек
        orderForSave.clear() //обнуляем ордер для записи
        reloadCell()
    }
    
    @objc func funcButtonUndelete() {
        
    }
    
    @objc func funcButtonCancel() {
        selectCellWithOrder.removeAll() //снимаем выделения со всех ячеек
        selectOrderForMove = nil
        orderForSave.clear() //обнуляем ордер для записи
        reloadCell()
    }
    
    @IBAction func buttonPreviousDate(_ sender: Any) {
        // save order if save data in orderForSave
        if !orderForSave.time.isEmpty {
            orderSave()
        }
        dateForLabel = dateForLabel.yesterday
        labelDate.text = dateForLabel.convertToString
        selectCellWithOrder.removeAll() //снимаем выделения со всех ячеек
        orderForSave.clear() //обнуляем ордер для записи
        selectOrderForMove = nil
        reloadCell()
    }
    
    @IBAction func buttonNextDate(_ sender: Any) {
        // save order if save data in orderForSave
        if !orderForSave.time.isEmpty {
            orderSave()
        }
        dateForLabel = dateForLabel.tomorrow
        labelDate.text = dateForLabel.convertToString
        selectCellWithOrder.removeAll() //снимаем выделения со всех ячеек
        orderForSave.clear() //обнуляем ордер для записи
        selectOrderForMove = nil
        reloadCell()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(drawLine (start: lineCoordinate.start, end: lineCoordinate.end, color: UIColor(ciColor: .black), weight: 3))
        labelConfig(label: labelFio)
        labelConfig(label: labelMaster)
        labelConfig(label: labelService)
        labelConfig(label: labelPhoneNumber)
        labelDate.text = dateForLabel.convertToString
        ordersTable = loadOrdersInDay(date: dateForLabel)
        do {
            mastersTable = try base.fetchContext(base: Bases.masters.rawValue, predicate: nil) as! [EntityMasters]
            servicesTable = try base.fetchContext(base: Bases.services.rawValue, predicate: nil) as! [EntityServices]
        }
        catch{
            fatalError("error load masters or service")
        }
        
        if let receivedText = selectClientPhone, !receivedText.isEmpty {
            if let clientTable = base.findClientByPhone(phone: receivedText) {
                labelFio.text = (clientTable.firstName ?? "") + " " + (clientTable.lastName ?? "")
                labelPhoneNumber.text = String(clientTable.phone)
                labelTitleView.text = clientTable.firstName
                selectClient = true
                orderForSave.client = clientTable
            }
        }
        
        self.collectionViewCalendar.delegate = self
        self.collectionViewCalendar.dataSource = self
        self.collectionViewCalendar.register(UINib(nibName: "CalendarCollectionViewCell", bundle: nil ) , forCellWithReuseIdentifier: idCell)
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(funcButtonSaveOrder))
        cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(funcButtonCancel))
        undeleteButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.trash, target: self, action: #selector(funcButtonUndelete))
        navigationItem.rightBarButtonItems = [undeleteButton!]
    }
    
    override func didMove(toParent parent: UIViewController?) {
        print ("did Move")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print ("view did appear")
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print ("deselect item cell")
        
        /*
         отмена выбора ячейки Условие: ячейка должна быть выбрана и зашли через календарь
         */
        if !selectClient && !selectCellWithOrder.isEmpty && selectOrderForMove == nil{
            selectCellWithOrder.removeAll()
            selectOrderForMove = nil
            collectionView.reloadItems(at: [indexPath])
            navigationItem.rightBarButtonItems = [undeleteButton!]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print ("didHighlightItemAt")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timeShiftArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionViewCalendar.dequeueReusableCell(withReuseIdentifier: idCell, for: indexPath) as! CalendarCollectionViewCell
        cell.label.text = timeShiftArray[indexPath.row]
        cell.backgroundColor = .white
        
        var cellText = CellText(clientName: "", masterName: "", service: "", backgroundColor: UIColor.white)
        
        if let order = ordersTable [indexPath.row] {
            cellText.clientName = order.orderToClient?.firstName ?? ""
            cellText.service = order.orderToService?.service ?? ""
            cellText.masterName = order.orderToMaster?.lastName ?? ""
            if order.orderToClient!.phone == Int(selectClientPhone ?? "0") ?? 0 {
                cell.backgroundColor = UIColor(named: "BackgroundLabel")
//                cell.layer.borderColor = UIColor.red.cgColor
//                cell.layer.borderWidth = 2
//                cell.clientName.font = .boldSystemFont(ofSize: cell.clientName.font.pointSize)
            }
        }
        
        
        /*
         отрисовывваем выделенные ячейки (ячейки в работе)
         */
        if let order = selectCellWithOrder [indexPath.row]{
            cellText.clientName = order.clientName
            cellText.service = order.service
            cellText.masterName = order.masterName
            cell.backgroundColor = order.backgroundColor
        }

        
        cell.clientName.text = cellText.clientName
        cell.service.text = cellText.service
        cell.masterName.text = cellText.masterName
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        cell.alpha = 0
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        /*
         выбор пустой ячейки для перемещения ордера
         */
        
        if selectCellWithOrder [indexPath.row] == nil && ordersTable[indexPath.row] == nil{
            print ("empty cell")
        }
        
        /*
         выбор заполненной ячейки, работа с этой ячейкой Удалить или редактировать(двигать), условие: существует ордер, зашли через календарь и не выбрана предыдущая ячейка для движения
         */
        if let order = ordersTable [indexPath.row], !selectClient, selectOrderForMove == nil{
            let clientName = order.orderToClient?.firstName ?? ""
            let masterName = order.orderToMaster?.lastName ?? ""
            let service = order.orderToService!.service!
            
            if let cell = collectionView.cellForItem(at: indexPath) as? CalendarCollectionViewCell {
            UIView.animate(withDuration: 0.2, animations: {cell.backgroundColor = .systemGreen})
                selectCellWithOrder[indexPath.row] = CellText(clientName: clientName, masterName: masterName, service: service, backgroundColor: UIColor.systemGreen)}
            

            labelFio.text = "Клиент: " + clientName + " " + (order.orderToClient?.lastName ?? "")
            labelPhoneNumber.text = "Телефон: " + String(order.orderToClient!.phone)
            labelMaster.text = "Мастер: " + (order.orderToMaster?.firstName ?? "") + " " + masterName
            labelService.text = "Услуга: " + service
            let deleteButton = BarButtonDelete(title: "Удалить", style: .plain, target: self, action: #selector(buttonDeleteOrder(sender:)))
            selectOrderForMove = indexPath.row
            deleteButton.order = order
            self.navigationItem.rightBarButtonItems = [deleteButton, cancelButton!]
        }
        
        
        
        /*
         выбор ячейки с ордером если зашли через клиента
         */
        if let order = ordersTable [indexPath.row], selectClient {
            let deleteButton = BarButtonDelete(title: "Удалить", style: .plain, target: self, action: #selector(buttonDeleteOrder(sender:)))
            deleteButton.order = order
            self.navigationItem.rightBarButtonItems = [deleteButton]
        }

        
        
        /*
         двигаем ячейку с ордером на новое выбранное место
         */
        if ordersTable [indexPath.row] == nil && selectOrderForMove != nil{
            dialogMessage(message: "Двигаем ордер?", funcOk: {
                if let order = self.ordersTable[self.selectOrderForMove!]{
                    do{
                        self.orderForSave.client = order.orderToClient
                        self.orderForSave.master = order.orderToMaster
                        self.orderForSave.service = order.orderToService
                        self.orderForSave.date = order.date
                        var time = order.time?.compactMap{time in time != self.selectOrderForMove! ? time:nil}
                        time?.append(UInt8(indexPath.row))
                        self.orderForSave.time.append(contentsOf: time!)
                        try self.base.deleteObject(object: order)
                        self.orderSave()
                    }
                    catch{
                        showMessage(message: error.localizedDescription)
                    }
                }
                else
                    {
                        showMessage(message: "select orders not found")
                    }
                self.selectOrderForMove = nil
                self.selectCellWithOrder.removeAll() //снимаем выделения со всех ячеек
                self.orderForSave.clear() //обнуляем ордер для записи
                self.reloadCell()
            },funcCancel: { self.funcButtonCancel() })
        }
        
        
        /*
         зашли через клиента, выбор пустой ячейки для записи нового ордера
         */
        if ordersTable [indexPath.row] == nil ,selectClient, self.selectCellWithOrder[indexPath.row] == nil {
            self.navigationItem.rightBarButtonItems = [saveButton!, cancelButton!]
            
            createPickerViewSelectMasterService(){
                let cell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
                let clientName = self.orderForSave.client?.firstName ?? ""
                let masterName = self.mastersTable[self.selectedMasterRow].lastName ?? ""
                let service = self.servicesTable[self.selectedServiceRow].service ?? ""
                self.selectCellWithOrder[indexPath.row] = CellText(clientName: clientName, masterName: masterName, service: service, backgroundColor: UIColor.systemGreen)
                cell.clientName.text = clientName
                cell.service.text = service
                cell.masterName.text = masterName
                
                UIView.animate(withDuration: 0.2, animations: {cell.backgroundColor = .systemGreen})
                
                //check change Master or Service in select another cell
                if self.checkChangeMasterOrService() && self.orderForSave.master != nil {
                // save old order with select another master or service
                    self.orderSave()
                    let newOrderCell = self.selectCellWithOrder[indexPath.row]
                    self.selectCellWithOrder.removeAll() //снимаем выделения со всех ячеек
                    self.reloadCell()
                    self.selectCellWithOrder[indexPath.row] = newOrderCell
                    self.navigationItem.rightBarButtonItems = [self.saveButton!, self.cancelButton!]
                }
                
                //сохраняем ордер во временную переменную
                self.orderForSave.master = self.mastersTable[self.selectedMasterRow]
                self.orderForSave.service = self.servicesTable[self.selectedServiceRow]
                self.orderForSave.date = self.dateForLabel
                self.orderForSave.time.append(UInt8(indexPath.row))
                self.labelMaster.text = (self.mastersTable[self.selectedMasterRow].lastName ?? "") + " " + (self.mastersTable[self.selectedMasterRow].firstName ?? "")
                self.labelService.text = self.servicesTable[self.selectedServiceRow].service

            }
        }
    }
    
    func checkChangeMasterOrService() -> Bool{
        if orderForSave.master != mastersTable[selectedMasterRow] { return true}
        if orderForSave.service != servicesTable[selectedServiceRow] {return true}
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let paddingSpace = sectionInsets.left * (itemsPerRow)
      let availableWidth = collectionViewCalendar.bounds.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
      return CGSize(width: widthPerItem, height: widthPerItem+10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: fontSizeForLabelSelectMaster))
        label.font = labelTitleView.font
        label.font = label.font.withSize(fontSizeForLabelSelectMaster)
        switch component{
        case 0:
            label.text = (mastersTable[row].firstName ?? "") + " " + (mastersTable[row].lastName ?? "")
        case 1:
            label.text = servicesTable[row].service
        default:
            label.text = ""
        }
        label.sizeToFit()
        return label
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component{
        case 0:
            return mastersTable.count
        case 1:
            return servicesTable.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return fontSizeForLabelSelectMaster*2
    }
    
    func createPickerViewSelectMasterService(finished: @escaping () -> Void){
        screenHeight = fontSizeForLabelSelectMaster * CGFloat(mastersTable.count == 0 ? 1 : mastersTable.count * 2)
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight!)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight!))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(selectedMasterRow, inComponent: 0, animated: false)
        pickerView.selectRow(selectedServiceRow, inComponent: 1, animated: false)
        vc.view.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        
        let alert = UIAlertController(title: "", message: "Выбери мастера и услугу", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = pickerView.bounds
        
        alert.setValue(vc, forKey: "ContentViewController")
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler:{ (UIAlertAction) in
            
            self.navigationItem.rightBarButtonItems = [self.undeleteButton!]
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            self.selectedMasterRow = pickerView.selectedRow(inComponent: 0)
            self.selectedServiceRow = pickerView.selectedRow(inComponent: 1)
            finished() }))

        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func labelConfig(label: UILabel){
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.opaqueSeparator.cgColor
        label.text = ""
    }
    
    func loadOrdersInDay(date: Date) -> [Int : EntityOrders]{
        var orders: [Int : EntityOrders] = [:]
        if let fetchResults = base.getOrdersInDate(date: date){
            for fetchResult in fetchResults {
                let order = fetchResult as! EntityOrders
                let times = order.time!
                for time in times {
                    orders[Int(time)] = order
                }
            }
        }
        return orders
    }
    
    func reloadCell(){
        ordersTable = loadOrdersInDay(date: dateForLabel)
        collectionViewCalendar.reloadData()
        navigationItem.rightBarButtonItems = [undeleteButton!]
    }

    func orderSave(){
        if base.saveOrders(date: orderForSave.date,
                        time: orderForSave.time,
                           client: orderForSave.client,
                           service: orderForSave.service,
                           master: orderForSave.master) != 1{
            showMessage(message: ValidationError.failedSaveOrder.errorDescription!)
        }
        else{
            animationSaveFinish(view: view, text: "Сохранено")
        }
        let client = orderForSave.client
        orderForSave = OrderForSave()
        orderForSave.client = client
    }
    
}

