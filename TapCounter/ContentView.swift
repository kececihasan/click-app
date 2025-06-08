import SwiftUI

// Weather API için model
struct WeatherData: Codable {
    let main: Main
    let weather: [Weather]
    let name: String
    
    struct Main: Codable {
        let temp: Double
        let humidity: Int
    }
    
    struct Weather: Codable {
        let main: String
        let description: String
        let icon: String
    }
}

// Hava durumu service
class WeatherService: ObservableObject {
    @Published var weatherData: [String: WeatherData] = [:]
    @Published var isLoading = false
    
    private let apiKey = "demo_key" // Gerçek API key için OpenWeatherMap'e kaydolun
    
    func fetchWeather(for city: String) {
        guard !city.isEmpty else { return }
        
        // Gerçek API kullanımı için API key'i OpenWeatherMap'ten alın
        if apiKey == "demo_key" {
            // Demo mode - simulated data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let simulatedWeather = self.getSimulatedWeather(for: city)
                self.weatherData[city] = simulatedWeather
            }
        } else {
            // Gerçek API çağrısı
            fetchRealWeather(for: city)
        }
    }
    
    private func fetchRealWeather(for city: String) {
        // URL encode için şehir adını düzelt
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity),TR&appid=\(apiKey)&units=metric&lang=tr"
        
        guard let url = URL(string: urlString) else { 
            // URL oluşturulamazsa simulated data kullan
            let simulatedWeather = getSimulatedWeather(for: city)
            weatherData[city] = simulatedWeather
            return 
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                guard let data = data, error == nil else {
                    // Network hatası - simulated data kullan
                    let simulatedWeather = self?.getSimulatedWeather(for: city)
                    self?.weatherData[city] = simulatedWeather
                    return
                }
                
                // HTTP status kontrolü
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode != 200 {
                    // API hatası - simulated data kullan
                    let simulatedWeather = self?.getSimulatedWeather(for: city)
                    self?.weatherData[city] = simulatedWeather
                    return
                }
                
                do {
                    let weather = try JSONDecoder().decode(WeatherData.self, from: data)
                    self?.weatherData[city] = weather
                } catch {
                    // Parse hatası - simulated data kullan
                    print("Weather API parse error: \(error)")
                    let simulatedWeather = self?.getSimulatedWeather(for: city)
                    self?.weatherData[city] = simulatedWeather
                }
            }
        }.resume()
    }
    
    private func getSimulatedWeather(for city: String) -> WeatherData {
        // Türkiye şehirlerine uygun gerçekçi sıcaklıklar
        let cityTemperatures: [String: [Double]] = [
            "Ankara": [8, 12, 16, 20],
            "İstanbul": [10, 14, 18, 22],
            "İzmir": [12, 16, 20, 24],
            "Antalya": [15, 18, 22, 26],
            "Trabzon": [8, 12, 16, 20],
            "Erzurum": [2, 6, 10, 14],
            "Van": [4, 8, 12, 16],
            "Muğla": [14, 18, 22, 26],
            "Rize": [9, 13, 17, 21],
            "Kars": [0, 4, 8, 12]
        ]
        
        // Hava durumu türleri ve Türkçe açıklamaları
        let weatherData = [
            ("Clear", "açık"),
            ("Clouds", "bulutlu"),
            ("Rain", "yağmurlu"),
            ("Snow", "karlı"),
            ("Drizzle", "çiseleyen"),
            ("Thunderstorm", "fırtınalı"),
            ("Mist", "puslu")
        ]
        
        // Şehre özel sıcaklık veya varsayılan
        let temps = cityTemperatures[city] ?? [8, 15, 20, 25, 28, 12, 30, 18, 26, 22]
        let temp = Double(temps.randomElement() ?? 20)
        
        // Rastgele hava durumu seç
        let selectedWeather = weatherData.randomElement() ?? ("Clear", "açık")
        let weatherType = selectedWeather.0
        let turkishDescription = selectedWeather.1
        
        return WeatherData(
            main: WeatherData.Main(temp: temp, humidity: Int.random(in: 40...80)),
            weather: [WeatherData.Weather(main: weatherType, description: turkishDescription, icon: "01d")],
            name: city
        )
    }
}

struct ContentView: View {
    @State private var tapCount = 0
    @State private var lastTapTime: Date?
    @State private var timeDifference: TimeInterval = 0
    @StateObject private var weatherService = WeatherService()
    
    // Türkiye plaka kodları ve şehirler (1-81)
    private let plateToCity: [Int: String] = [
        1: "Adana", 2: "Adıyaman", 3: "Afyonkarahisar", 4: "Ağrı", 5: "Amasya",
        6: "Ankara", 7: "Antalya", 8: "Artvin", 9: "Aydın", 10: "Balıkesir",
        11: "Bilecik", 12: "Bingöl", 13: "Bitlis", 14: "Bolu", 15: "Burdur",
        16: "Bursa", 17: "Çanakkale", 18: "Çankırı", 19: "Çorum", 20: "Denizli",
        21: "Diyarbakır", 22: "Edirne", 23: "Elazığ", 24: "Erzincan", 25: "Erzurum",
        26: "Eskişehir", 27: "Gaziantep", 28: "Giresun", 29: "Gümüşhane", 30: "Hakkâri",
        31: "Hatay", 32: "Isparta", 33: "Mersin", 34: "İstanbul", 35: "İzmir",
        36: "Kars", 37: "Kastamonu", 38: "Kayseri", 39: "Kırklareli", 40: "Kırşehir",
        41: "Kocaeli", 42: "Konya", 43: "Kütahya", 44: "Malatya", 45: "Manisa",
        46: "Kahramanmaraş", 47: "Mardin", 48: "Muğla", 49: "Muş", 50: "Nevşehir",
        51: "Niğde", 52: "Ordu", 53: "Rize", 54: "Sakarya", 55: "Samsun",
        56: "Siirt", 57: "Sinop", 58: "Sivas", 59: "Tekirdağ", 60: "Tokat",
        61: "Trabzon", 62: "Tunceli", 63: "Şanlıurfa", 64: "Uşak", 65: "Van",
        66: "Yozgat", 67: "Zonguldak", 68: "Aksaray", 69: "Bayburt", 70: "Karaman",
        71: "Kırıkkale", 72: "Batman", 73: "Şırnak", 74: "Bartın", 75: "Ardahan",
        76: "Iğdır", 77: "Yalova", 78: "Karabük", 79: "Kilis", 80: "Osmaniye",
        81: "Düzce"
    ]
    
    // Her şehrin meşhur olduğu şey ve fotoğraf adı
    private let cityFamousFor: [Int: (item: String, photo: String)] = [
        1: ("Kebap", "adana_kebap"),
        2: ("Nemrut Dağı", "nemrut_dagi"),
        3: ("Afyon & Kaymak", "afyon_kaymak"),
        4: ("Ağrı Dağı", "agri_dagi"),
        5: ("Elma", "amasya_elma"),
        6: ("Başkent", "ankara_anitkabir"),
        7: ("Turizm", "antalya_sahil"),
        8: ("Çay", "artvin_cay"),
        9: ("İncir", "aydin_incir"),
        10: ("Zeytin", "balikesir_zeytin"),
        11: ("İpek", "bilecik_ipek"),
        12: ("Bal", "bingol_bal"),
        13: ("Van Gölü", "bitlis_van_golu"),
        14: ("Orman", "bolu_orman"),
        15: ("Göller", "burdur_goller"),
        16: ("İpek & Otomotiv", "bursa_otomotiv"),
        17: ("Truva", "canakkale_truva"),
        18: ("Tuz", "cankiri_tuz"),
        19: ("Leblebi", "corum_leblebi"),
        20: ("Tekstil", "denizli_tekstil"),
        21: ("Karpuz", "diyarbakir_karpuz"),
        22: ("Meriç Nehri", "edirne_meric"),
        23: ("Harput", "elazig_harput"),
        24: ("Tulum Peyniri", "erzincan_tulum"),
        25: ("Cağ Kebabı", "erzurum_cag_kebab"),
        26: ("Lületaşı", "eskisehir_luletasi"),
        27: ("Baklava", "gaziantep_baklava"),
        28: ("Fındık", "giresun_findik"),
        29: ("Gümüş", "gumushane_gumus"),
        30: ("Bal", "hakkari_bal"),
        31: ("Künefe", "hatay_kunefe"),
        32: ("Gül", "isparta_gul"),
        33: ("Narenciye", "mersin_narenciye"),
        34: ("Kültür & Tarih", "istanbul_ayasofya"),
        35: ("Ege Denizi", "izmir_saat_kulesi"),
        36: ("Kaşar Peyniri", "kars_kasar"),
        37: ("Kastamonu Türküsü", "kastamonu_turkusu"),
        38: ("Pastırma", "kayseri_pastirma"),
        39: ("Bağcılık", "kirklareli_bagcilik"),
        40: ("Halı", "kirsehir_hali"),
        41: ("Sanayi", "kocaeli_sanayi"),
        42: ("Sema", "konya_sema"),
        43: ("Porselen", "kutahya_porselen"),
        44: ("Kayısı", "malatya_kayisi"),
        45: ("Üzüm", "manisa_uzum"),
        46: ("Dondurma", "maras_dondurma"),
        47: ("Taş İşçiliği", "mardin_tas"),
        48: ("Bal", "mugla_bal"),
        49: ("Hayvancılık", "mus_hayvancilik"),
        50: ("Peribacaları", "nevsehir_peribacalari"),
        51: ("Patates", "nigde_patates"),
        52: ("Fındık", "ordu_findik"),
        53: ("Çay", "rize_cay"),
        54: ("Adapazarı Köftesi", "sakarya_kofte"),
        55: ("Pide", "samsun_pide"),
        56: ("Şırnak Balı", "siirt_bal"),
        57: ("Boyabat", "sinop_boyabat"),
        58: ("Kangal Köpeği", "sivas_kangal"),
        59: ("Rakı", "tekirdag_raki"),
        60: ("Tokat Kebabı", "tokat_kebab"),
        61: ("Hamsi", "trabzon_hamsi"),
        62: ("Munzur Dağları", "tunceli_munzur"),
        63: ("Urfa Kebabı", "urfa_kebab"),
        64: ("Halı", "usak_hali"),
        65: ("Van Kedisi", "van_kedisi"),
        66: ("Tarhana", "yozgat_tarhana"),
        67: ("Kömür", "zonguldak_komur"),
        68: ("Tuz Gölü", "aksaray_tuz_golu"),
        69: ("Bafra", "bayburt_bafra"),
        70: ("Ermenek Elması", "karaman_elma"),
        71: ("Demir", "kirikkale_demir"),
        72: ("Petrol", "batman_petrol"),
        73: ("Sınır", "sirnak_sinir"),
        74: ("Bartın Çayı", "bartin_cay"),
        75: ("Kars Gravyeri", "ardahan_gravyer"),
        76: ("Kayısı", "igdir_kayisi"),
        77: ("Termal", "yalova_termal"),
        78: ("Demir Çelik", "karabuk_demir"),
        79: ("Zeytin", "kilis_zeytin"),
        80: ("Düğün", "osmaniye_dugun"),
        81: ("Orman", "duzce_orman")
    ]
    
    // Mevcut plaka numarası (1-81 arası)
    var currentPlateNumber: Int {
        if tapCount == 0 {
            return 0
        } else {
            return ((tapCount - 1) % 81) + 1
        }
    }
    
    // Mevcut şehir
    var currentCity: String {
        if tapCount == 0 {
            return "Başlamak için dokunun"
        }
        return plateToCity[currentPlateNumber] ?? ""
    }
    
    // Mevcut şehrin meşhur olduğu şey
    var currentFamousItem: (item: String, photo: String) {
        if tapCount == 0 {
            return ("", "placeholder")
        }
        return cityFamousFor[currentPlateNumber] ?? ("", "placeholder")
    }
    
    // Mevcut hava durumu
    var currentWeather: WeatherData? {
        return weatherService.weatherData[currentCity]
    }
    
    // Renk kategorileri - plaka numarasına göre
    private let colorCategories: [(name: String, hue: Double)] = [
        ("Kırmızı", 0),      // 1-10: Kırmızı tonları
        ("Turuncu", 30),     // 11-20: Turuncu tonları
        ("Sarı", 60),        // 21-30: Sarı tonları
        ("Yeşil", 120),      // 31-40: Yeşil tonları
        ("Cyan", 180),       // 41-50: Cyan tonları
        ("Mavi", 240),       // 51-60: Mavi tonları
        ("Mor", 280),        // 61-70: Mor tonları
        ("Pembe", 320)       // 71-81: Pembe tonları
    ]
    
    var currentColorCategory: (name: String, hue: Double) {
        if tapCount == 0 {
            return ("Gri", 0)
        }
        let categoryIndex = min((currentPlateNumber - 1) / 10, colorCategories.count - 1)
        return colorCategories[categoryIndex]
    }
    
    var currentColors: [Color] {
        if tapCount == 0 {
            return [Color.gray.opacity(0.3), Color.gray.opacity(0.5)]
        }
        
        let category = currentColorCategory
        let positionInCategory = (currentPlateNumber - 1) % 10
        
        // 0-9 arası pozisyona göre ton değişimi
        let progress = Double(positionInCategory) / 9.0
        
        // İlk renk: Açık ton
        let lightColor = Color(hue: category.hue / 360.0, 
                              saturation: 0.4 + (progress * 0.3), 
                              brightness: 0.85 - (progress * 0.15))
        
        // İkinci renk: Koyu ton
        let darkColor = Color(hue: category.hue / 360.0, 
                             saturation: 0.6 + (progress * 0.4), 
                             brightness: 0.7 - (progress * 0.2))
        
        return [lightColor, darkColor]
    }
    
    var plateProgressText: String {
        if tapCount == 0 {
            return "Türkiye Plaka Sistemi (1-81)"
        }
        
        let categoryIndex = (currentPlateNumber - 1) / 10
        let positionInCategory = (currentPlateNumber - 1) % 10 + 1
        let categoryName = currentColorCategory.name
        let rangeStart = categoryIndex * 10 + 1
        let rangeEnd = min((categoryIndex + 1) * 10, 81)
        
        return "\(categoryName) bölgesi: \(rangeStart)-\(rangeEnd) arası (\(positionInCategory)/\(rangeEnd - rangeStart + 1))"
    }
    
    var formattedTimeDifference: String {
        if timeDifference == 0 {
            return "İlk tıklama"
        } else if timeDifference < 1 {
            return String(format: "%.3f sn", timeDifference)
        } else {
            return String(format: "%.2f sn", timeDifference)
        }
    }
    
    var timeDifferenceColor: Color {
        if timeDifference == 0 {
            return .white.opacity(0.7)
        } else if timeDifference < 0.5 {
            return .green
        } else if timeDifference < 1.0 {
            return .yellow
        } else if timeDifference < 2.0 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        ZStack {
            // Gradient background - plaka numarasına göre
            LinearGradient(
                colors: currentColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.6), value: currentPlateNumber)
            
            ScrollView {
                VStack(spacing: 12) {
                    Text("Türkiye Plaka Sayacı")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(.top)
                    
                    // Plaka numarası display
                    VStack(spacing: 8) {
                        if tapCount > 0 {
                            // Plaka numarası
                            HStack {
                                Text("\(String(format: "%02d", currentPlateNumber))")
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                                    .scaleEffect(tapCount > 0 ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: tapCount)
                            }
                            
                            // Şehir adı
                            Text(currentCity)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white.opacity(0.2))
                                        .shadow(color: .black.opacity(0.2), radius: 5)
                                )
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentCity)
                            
                            // Hava durumu
                            if weatherService.isLoading && currentWeather == nil {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Hava durumu yükleniyor...")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .shadow(color: .black.opacity(0.15), radius: 3)
                                )
                            } else if let weather = currentWeather {
                                HStack(spacing: 8) {
                                    Image(systemName: getWeatherIcon(for: weather.weather.first?.main ?? "Clear"))
                                        .foregroundColor(.white)
                                        .font(.subheadline)
                                    Text("\(Int(weather.main.temp))°C")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(weather.weather.first?.description.capitalized ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                    Text("•")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("💧\(weather.main.humidity)%")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(.horizontal, 15)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .shadow(color: .black.opacity(0.15), radius: 3)
                                )
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: weather.main.temp)
                            }
                            
                            // Meşhur olan şey - Fotoğraf benzeri görsel
                            VStack(spacing: 8) {
                                // Fotoğraf tarzı arka plan ve SF Symbol
                                ZStack {
                                    // Arka plan görseli
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 120, height: 120)
                                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.white.opacity(0.4), lineWidth: 2)
                                        )
                                    
                                    // SF Symbol içerik
                                    Image(systemName: getPhotoSymbol(for: currentPlateNumber))
                                        .font(.system(size: 50, weight: .medium))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                                }
                                .scaleEffect(1.1)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: currentFamousItem.photo)
                                
                                Text("Meşhur: \(currentFamousItem.item)")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .shadow(radius: 3)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.15))
                                            .shadow(color: .black.opacity(0.15), radius: 3)
                                    )
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentFamousItem.item)
                            }
                        } else {
                            Text("00")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("Başlamak için dokunun")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Image(systemName: "photo")
                                    .font(.system(size: 30, weight: .light))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        
                        Text("Plaka: \(tapCount) / 81 il")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(radius: 3)
                    }
                    
                    // Renk bölgesi göstergesi
                    if tapCount > 0 {
                        VStack(spacing: 6) {
                            HStack {
                                Image(systemName: "location.circle")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Bölge Durumu")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Text(plateProgressText)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                                .shadow(radius: 3)
                            
                            // Progress bar (bölge içi ilerleme)
                            let progress = Double((currentPlateNumber - 1) % 10) / 9.0
                            HStack(spacing: 2) {
                                ForEach(0..<10, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Double(index) / 9.0 <= progress ? Color.white.opacity(0.9) : Color.white.opacity(0.3))
                                        .frame(width: 12, height: 6)
                                        .animation(.easeInOut(duration: 0.3), value: currentPlateNumber)
                                }
                            }
                            .padding(.top, 3)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.1))
                                .shadow(color: .black.opacity(0.2), radius: 5)
                        )
                    }
                    
                    // Time difference display
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "stopwatch")
                                .foregroundColor(timeDifferenceColor)
                            Text("Tıklama Hızı")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text(formattedTimeDifference)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(timeDifferenceColor)
                            .shadow(radius: 3)
                            .scaleEffect(timeDifference > 0 ? 1.05 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: timeDifference)
                        
                        // Speed indicator
                        HStack(spacing: 4) {
                            ForEach(0..<5, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(speedIndicatorColor(for: index))
                                    .frame(width: 25, height: 4)
                                    .animation(.easeInOut(duration: 0.3), value: timeDifference)
                            }
                        }
                        .padding(.top, 3)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.1))
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    )
                    
                    // Sonraki şehirler önizlemesi
                    if tapCount > 0 && tapCount < 81 {
                        HStack(spacing: 12) {
                            Text("Sonraki:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            ForEach(1..<min(4, 82 - currentPlateNumber), id: \.self) { offset in
                                let nextPlate = currentPlateNumber + offset
                                VStack(spacing: 2) {
                                    Text("\(String(format: "%02d", nextPlate))")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(plateToCity[nextPlate] ?? "")
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.6))
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    
                    // Reset button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            tapCount = 0
                            lastTapTime = nil
                            timeDifference = 0
                            weatherService.weatherData.removeAll()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Sıfırla")
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.2))
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        )
                    }
                    .disabled(tapCount == 0)
                    .opacity(tapCount == 0 ? 0.5 : 1.0)
                    
                    if tapCount == 81 {
                        Text("🎉 Türkiye'nin tüm illerini tamamladınız! 🎉")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .shadow(radius: 5)
                    } else {
                        Text("Dokunarak Türkiye'nin 81 ilini, hava durumlarını ve meşhur özelliklerini keşfedin!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .onTapGesture {
            if tapCount < 81 {
                let currentTime = Date()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    tapCount += 1
                    
                    // Zaman farkını hesapla
                    if let lastTime = lastTapTime {
                        timeDifference = currentTime.timeIntervalSince(lastTime)
                    } else {
                        timeDifference = 0
                    }
                    
                    lastTapTime = currentTime
                }
                
                // Hava durumunu çek
                weatherService.fetchWeather(for: currentCity)
                
                // Haptic feedback - özel şehirler için güçlü
                let specialCities = [6, 34, 35] // Ankara, İstanbul, İzmir
                if specialCities.contains(currentPlateNumber) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                    impactFeedback.impactOccurred()
                } else {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            }
        }
    }
    
    private func speedIndicatorColor(for index: Int) -> Color {
        let speedLevel = getSpeedLevel()
        return index < speedLevel ? timeDifferenceColor.opacity(0.8) : Color.white.opacity(0.3)
    }
    
    private func getSpeedLevel() -> Int {
        if timeDifference == 0 {
            return 0
        } else if timeDifference < 0.3 {
            return 5 // Çok hızlı
        } else if timeDifference < 0.6 {
            return 4 // Hızlı
        } else if timeDifference < 1.0 {
            return 3 // Orta
        } else if timeDifference < 2.0 {
            return 2 // Yavaş
        } else {
            return 1 // Çok yavaş
        }
    }
    
    // Her şehrin meşhur özelliği için SF Symbol döndürür
    private func getPhotoSymbol(for plateNumber: Int) -> String {
        let photoSymbols: [Int: String] = [
            1: "flame.fill",                    // Kebap
            2: "mountain.2.fill",               // Nemrut Dağı
            3: "drop.fill",                     // Afyon & Kaymak
            4: "mountain.2.fill",               // Ağrı Dağı
            5: "apple.logo",                    // Elma
            6: "building.columns.fill",         // Başkent
            7: "beach.umbrella.fill",           // Turizm
            8: "leaf.fill",                     // Çay
            9: "circle.fill",                   // İncir
            10: "leaf.circle.fill",             // Zeytin
            11: "sparkles",                     // İpek
            12: "honeybee.fill",                // Bal
            13: "drop.triangle.fill",           // Van Gölü
            14: "tree.fill",                    // Orman
            15: "water.waves",                  // Göller
            16: "car.fill",                     // İpek & Otomotiv
            17: "building.2.fill",              // Truva
            18: "cube.fill",                    // Tuz
            19: "circle.dotted",                // Leblebi
            20: "tshirt.fill",                  // Tekstil
            21: "circle.hexagongrid.fill",      // Karpuz
            22: "water.waves",                  // Meriç Nehri
            23: "building.2.fill",              // Harput
            24: "circle.dashed",                // Tulum Peyniri
            25: "flame.fill",                   // Cağ Kebabı
            26: "sparkles",                     // Lületaşı
            27: "birthday.cake.fill",           // Baklava
            28: "leaf.circle.fill",             // Fındık
            29: "sparkles",                     // Gümüş
            30: "honeybee.fill",                // Bal
            31: "birthday.cake.fill",           // Künefe
            32: "flower.fill",                  // Gül
            33: "circle.fill",                  // Narenciye
            34: "building.2.fill",              // Kültür & Tarih
            35: "water.waves",                  // Ege Denizi
            36: "circle.dotted",                // Kaşar Peyniri
            37: "music.note",                   // Kastamonu Türküsü
            38: "flame.fill",                   // Pastırma
            39: "leaf.fill",                    // Bağcılık
            40: "square.grid.3x3.fill",         // Halı
            41: "gear",                         // Sanayi
            42: "figure.dance",                 // Sema
            43: "cup.and.saucer.fill",          // Porselen
            44: "circle.fill",                  // Kayısı
            45: "leaf.circle.fill",             // Üzüm
            46: "snowflake",                    // Dondurma
            47: "building.2.fill",              // Taş İşçiliği
            48: "honeybee.fill",                // Bal
            49: "pawprint.fill",                // Hayvancılık
            50: "mountain.2.fill",              // Peribacaları
            51: "circle.fill",                  // Patates
            52: "leaf.circle.fill",             // Fındık
            53: "leaf.fill",                    // Çay
            54: "flame.fill",                   // Adapazarı Köftesi
            55: "flame.fill",                   // Pide
            56: "honeybee.fill",                // Şırnak Balı
            57: "building.2.fill",              // Boyabat
            58: "dog.fill",                     // Kangal Köpeği
            59: "wineglass.fill",               // Rakı
            60: "flame.fill",                   // Tokat Kebabı
            61: "fish.fill",                    // Hamsi
            62: "mountain.2.fill",              // Munzur Dağları
            63: "flame.fill",                   // Urfa Kebabı
            64: "square.grid.3x3.fill",         // Halı
            65: "cat.fill",                     // Van Kedisi
            66: "bowl.fill",                    // Tarhana
            67: "cube.fill",                    // Kömür
            68: "drop.triangle.fill",           // Tuz Gölü
            69: "leaf.fill",                    // Bafra
            70: "apple.logo",                   // Ermenek Elması
            71: "cube.fill",                    // Demir
            72: "drop.fill",                    // Petrol
            73: "map.fill",                     // Sınır
            74: "water.waves",                  // Bartın Çayı
            75: "circle.dotted",                // Kars Gravyeri
            76: "circle.fill",                  // Kayısı
            77: "thermometer.medium",           // Termal
            78: "cube.fill",                    // Demir Çelik
            79: "leaf.circle.fill",             // Zeytin
            80: "heart.fill",                   // Düğün
            81: "tree.fill"                     // Orman
        ]
        
        return photoSymbols[plateNumber] ?? "photo"
    }
    
    // Hava durumu türüne göre ikon döndürür
    private func getWeatherIcon(for weatherType: String) -> String {
        switch weatherType.lowercased() {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "cloud.fill"
        case "rain":
            return "cloud.rain.fill"
        case "drizzle":
            return "cloud.drizzle.fill"
        case "thunderstorm":
            return "cloud.bolt.rain.fill"
        case "snow":
            return "cloud.snow.fill"
        case "mist", "fog":
            return "cloud.fog.fill"
        default:
            return "thermometer.medium"
        }
    }
}

#Preview {
    ContentView()
} 