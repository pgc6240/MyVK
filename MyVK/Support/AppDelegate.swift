//
//  AppDelegate.swift
//  MyVK
//
//  Created by pgc6240 on 24.10.2020.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = LoginVC()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
        coder.encode(PersistenceManager.appVersion, forKey: PersistenceManager.Keys.appVersion)
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
        return coder.decodeObject(forKey: PersistenceManager.Keys.appVersion) as? String == PersistenceManager.appVersion
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        PersistenceManager.save()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        PersistenceManager.load()
    }
}


//
// MARK: - Dummy data
//
let firstNames: [String] = ["Иван", "Пётр", "Николай", "Митрофан", "Эльдар", "Ашот", "Юлий", "Аггей", "Прокофий", "Люсьен", "Герасим", "Христофор", "Ипполит", "Артур", "Никита", "Ибрагим", "Ерофей", "Вячеслав", "Петр", "Яков", "Петр", "Владислав", "Станимир", "Семен", "Виктор", "Ратибор", "Виталий", "Никифор", "Карл", "Фридрих", "Цезарь", "Ерофей", "Гарри", "Филимон", "Радий", "Марат", "Иероним", "Евстафий", "Автандил", "Муслим", "Ефимий", "Фарид", "Ефрем", "Никифор", "Ксанф", "Ангел", "Левон", "Алан", "Эдгар", "Азарий", "Иосиф", "Максимилиан", "Чингиз", "Еремей", "Эдуард", "Моисей", "Гевор", "Арнольд", "Рафаил", "Гастон", "Генрих", "Артем", "Рустам", "Жан", "Давид", "Мартин", "Клемент", "Ашот", "Владимир", "Стоян", "Жорж", "Густав", "Герасим", "Гордей", "Лука", "Евстафий", "Фуад", "Авдей", "Норманн", "Рамиз", "Рамиз", "Ефим", "Анатолий", "Осип", "Левон", "Христофор", "Ратибор", "Виссарион", "Лука", "Мефодий", "Конрад", "Шамиль", "Адриан", "Фарид", "Прохор", "Армен", "Дмитрий", "Тит", "Клим", "Ратибор", "Равиль", "Агафон", "Клемент"]

let lastNames: [String] = ["Иванов", "Петров", "Тарасов", "Лисицын", "Худяков", "Снаткин", "Юганцев", "Королёв", "Кошкин", "Чебыкин", "Суханов", "Голумбовский", "Пичушкин", "Паршин", "Трофимов", "Караулин", "Шверник", "Деникин", "Варенников", "Гринин", "Ельчуков", "Афанасьев", "Слобожанин", "Золотов", "Полтанов", "Будников", "Суворов", "Есипов", "Домашев", "Баренцев", "Щедров", "Лаврентьев", "Грачёв", "Путинов", "Маликов", "Травкин", "Валевач", "Машарин", "Ходяев", "Гусев", "Теплов", "Фененко", "Черепанов", "Ежов", "Богров", "Мамин", "Осинцев", "Соболевский", "Новокшонов", "Свалов", "Экель", "Бурков", "Беломестнов", "Перминов", "Круглов", "Курганов", "Калагин", "Ильин", "Снегирёв", "Румянцев", "Ермилов", "Полтанов", "Старцев", "Репин", "Северинов", "Чижиков", "Погребнов", "Головин", "Савинков", "Якушев", "Фёдоров", "Скоробогатов", "Ханцев", "Вахров", "Иноземцев", "Горохин", "Беломестов", "Булыгин", "Полотенцев", "Савасин", "Никифоров", "Луков", "Сычёв", "Карандашов", "Чупров", "Белоусов", "Барсуков", "Конников", "Рассказов", "Полотенцев", "Гавриков", "Голубов", "Ледовской", "Гавриков", "Шкуратов", "Мирнов", "Осинцев", "Любимов", "Палюлин", "Валевач", "Денисов", "Авдеев"]

func makeFriend() -> User {
    var randomFirstName = firstNames.randomElement() ?? "Иван"
    var randomLastName  = lastNames.randomElement() ?? "Иванов"
    
    if Locale.current.languageCode == "en" {
        randomFirstName = randomFirstName.toLatin
        randomLastName  = randomLastName.toLatin
    }
    
    return User(firstName: randomFirstName, lastName: randomLastName)
}

func makeRandomNumberOfFriends(upTo: Int) -> [User] {
    var tempFriends = [User]()
    for _ in 1...Int.random(in: 1...upTo) {
        tempFriends.append(makeFriend())
    }
    return tempFriends
}

let somePhotos = [Photo(imageName: "photo-1"), Photo(imageName: "photo-2"), Photo(imageName: "photo-1")]

let somePosts: [Post] = [
    Post(text: "Какой-то очень интересный пост.", photos: somePhotos, likeCount: 50, viewCount: 697),
    Post(text: "Ещё более интересный пост.", photos: somePhotos.dropLast(), likeCount: 107, viewCount: 1012),
    Post(text: "Не очень интересный пост.", photos: [somePhotos[1]], likeCount: 25, viewCount: 273)
]
