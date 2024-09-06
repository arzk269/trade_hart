import 'package:trade_hart/model/product.dart';
import 'package:trade_hart/model/seller.dart';

List<Seller> sellers = [
  Seller(name: "fashion boy", products: [
    Product(
        name: "Tshirt blanc",
        description:
            "Ce t-shirt blanc est un vêtement classique et polyvalent qui peut être porté avec n’importe quel pantalon ou short. Il est fabriqué à partir de coton doux et confortable, ce qui le rend parfait pour une utilisation quotidienne. Disponible en plusieurs tailles.",
        price: 10,
        imagePath: "images/fashion_boy_images/Tshirt_blanc.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "short",
        description:
            "Ce short est un vêtement d’été élégant et confortable. Il est fabriqué à partir de tissu léger et respirant, ce qui le rend parfait pour les journées chaudes. Disponible en plusieurs tailles.",
        price: 8,
        imagePath: "images/fashion_boy_images/short.jpg",
        rate: 3,
        nbRates: 500)
  ]),
  Seller(name: "flower passion", products: [
    Product(
        name: "rose",
        description:
            "Les roses sont des fleurs romantiques et colorées qui ajoutent une touche d'amour à n’importe quel jardin esprit. Elles sont faciles à cultiver et sont disponibles dans une variété de couleurs et de tailles. Les tulipes sont parfaites pour les jardins de printemps.",
        price: 10,
        imagePath: "images/flower_passion_image/rose.jpg",
        rate: 4,
        nbRates: 200),
    Product(
        name: "tulipes",
        description:
            "Les tulipes sont des fleurs élégantes et colorées qui ajoutent une touche de beauté à n’importe quel jardin. Offrez celle-ci à l'élu de votre coeur.",
        price: 15,
        imagePath: "images/flower_passion_image/tulipes.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "orchidées",
        description:
            "Les orchidées sont des plantes élégantes et exotiques qui ajoutent une touche de sophistication à n’importe quelle pièce. Elles sont disponibles dans une variété de couleurs et de tailles et sont faciles à entretenir. Les orchidées sont parfaites pour les maisons et les bureaux.",
        price: 8,
        imagePath: "images/flower_passion_image/orchidées.jpg",
        rate: 3,
        nbRates: 500)
  ]),
  Seller(name: "car hub", products: [
    Product(
        name: "BMW M3 G80",
        description:
            "La BMW M3 G90 est une voiture de sport élégante et puissante qui offre une expérience de conduite exceptionnelle. Elle est équipée d’un moteur V8 biturbo de 3,0 litres qui produit 473 chevaux et peut atteindre une vitesse maximale de 290 km/h. La BMW M3 G90 est la voiture parfaite pour les amateurs de voitures de sport.",
        price: 120000,
        imagePath: "images/car_hub_images/BMW_M3.jpg",
        rate: 4,
        nbRates: 200),
    Product(
        name: "Golf 7 GTI",
        description:
            "La Golf 7 GTI est une voiture compacte et sportive qui offre une expérience de conduite amusante et excitante. Elle est équipée d’un moteur turbo de 2,0 litres qui produit 220 chevaux et peut atteindre une vitesse maximale de 244 km/h. La Golf 7 GTI est la voiture parfaite pour les conducteurs qui recherchent une voiture compacte et sportive.",
        price: 60000,
        imagePath: "images/car_hub_images/Golf_7_GTI.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "Audi RS3",
        description:
            "L’Audi RS3 est une voiture compacte et sportive qui offre une expérience de conduite exceptionnelle. Elle est équipée d’un moteur turbo de 2,5 litres qui produit 400 chevaux et peut atteindre une vitesse maximale de 280 km/h. L’Audi RS3 est la voiture parfaite pour les conducteurs qui recherchent une voiture compacte et sportive.",
        price: 90000,
        imagePath: "images/car_hub_images/Audi_RS3.jpg",
        rate: 3,
        nbRates: 500)
  ]),
  Seller(name: "e-devices", products: [
    Product(
        name: "iPhone 15",
        description:
            "L’iPhone 15 est un smartphone perforrmant et puissant qui offre une expérience utilisateur exceptionnelle. Il est équipé d’un écran OLED de 6,7 pouces, d’un processeur A17 Bionic et d’un appareil photo de 64 mégapixels. L’iPhone 15 est le téléphone parfait pour les utilisateurs qui recherchent un smartphone haut de gamme.",
        price: 800,
        imagePath: "images/e-devices_images/iPhone_15.jpg",
        rate: 4,
        nbRates: 200),
    Product(
        name: "Xbox X series",
        description:
            "La Xbox Series X est une console de jeu puissante qui offre une expérience de jeu exceptionnelle. Elle est équipée d’un processeur AMD Zen 2 personnalisé et d’une carte graphique AMD RDNA 2 personnalisée. La Xbox Series X est la console de jeu parfaite pour les joueurs qui recherchent une expérience de jeu de haute qualité.",
        price: 500,
        imagePath: "images/e-devices_images/Xbox_X_series.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "Macbook air",
        description:
            "Le MacBook Air est un ordinateur portable élégant et puissant qui offre une expérience utilisateur exceptionnelle. Il est équipé d’un processeur M2 personnalisé, d’un écran Retina de 13,3 pouces et d’une batterie longue durée. Le MacBook Air est l’ordinateur portable parfait pour les utilisateurs qui recherchent un ordinateur portable haut de gamme.",
        price: 980,
        imagePath: "images/e-devices_images/macBook_air.jpg",
        rate: 3,
        nbRates: 500)
  ]),
  Seller(name: "art lovers", products: [
    Product(
        name: "tableau plage",
        description:
            "Ce tableau de plage est une œuvre d’art élégante et colorée qui ajoute une touche de beauté à n’importe quelle pièce. Il est fabriqué à partir de matériaux de haute qualité et est disponible en plusieurs tailles.",
        price: 200,
        imagePath: "images/art_lovers_images/tableau_plage.jpg",
        rate: 4,
        nbRates: 200),
    Product(
        name: "sculpture femme",
        description:
            "Cette sculpture de femme est une œuvre d’art élégante et sophistiquée qui ajoute une touche de beauté à n’importe quelle pièce. Elle est fabriquée à partir de matériaux de haute qualité et est disponible en plusieurs tailles",
        price: 120,
        imagePath: "images/art_lovers_images/sculpture_femme.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "tableau fruits",
        description:
            " Ce tableau de fruits est une œuvre d’art élégante et colorée qui ajoute une touche de beauté à n’importe quelle pièce. Il est fabriqué à partir de matériaux de haute qualité et est disponible en plusieurs tailles.",
        price: 80,
        imagePath: "images/art_lovers_images/tableau_fruit.jpg",
        rate: 3,
        nbRates: 500)
  ]),
  Seller(name: "house elec", products: [
    Product(
        name: "aspirateur",
        description:
            " Cet aspirateur est un appareil électroménager indispensable pour nettoyer tapis, moquettes et sols. Il est disponible en plusieurs modèles, y compris les aspirateurs traîneaux, balais sans fil, robots et bidons. Les technologies incluent des aspirateurs avec ou sans sac, aspiration centralisée, etc.",
        price: 753,
        imagePath: "images/house_elec_images/aspirateur.jpg",
        rate: 4,
        nbRates: 200),
    Product(
        name: "lave linge",
        description:
            "Ce lave-linge est un appareil électroménager qui permet de laver les vêtements. Il est disponible en plusieurs modèles, y compris les lave-linges à chargement frontal et les lave-linges à chargement par le haut. Les lave-linges modernes sont équipés de nombreuses fonctionnalités, telles que des programmes de lavage spéciaux, des écrans LCD, des options de connectivité, etc.",
        price: 920,
        imagePath: "images/house_elec_images/lave_linge.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "réfrigérateur",
        description:
            "Ce réfrigérateur est un appareil électroménager qui permet de stocker des aliments frais et surgelés dans un même appareil. Il est disponible en plusieurs modèles, y compris les réfrigérateurs à deux portes, les réfrigérateurs à une porte, les réfrigérateurs à congélateur en haut et les réfrigérateurs à congélateur en bas. Les réfrigérateurs modernes sont équipés de nombreuses fonctionnalités, telles que des écrans LCD, des options de connectivité, des distributeurs d’eau et de glace, etc. Il est impératif d’utiliser une prise directe équipée d’une terre. ",
        price: 800,
        imagePath: "images/house_elec_images/réfrigérateur.jpg",
        rate: 3,
        nbRates: 500)
  ]),
  Seller(name: "moto shop", products: [
    Product(
        name: "T-max",
        description:
            "Le T-max est un scooter de taille moyenne proposé par Yamaha. Ce modèle dispose d’un moteur puissant, offrant une accélération rapide et une vitesse maximale élevée. Le T-max est également équipé d’un système de freinage performant, doté de disques de frein de qualité supérieure. La suspension avant et arrière, spécialement conçue pour améliorer la stabilité et le confort durant la conduite, assure une expérience de conduite agréable pour le conducteur et le passager. Le design du T-max est élégant et moderne, avec une finition de qualité supérieure. La selle est confortable, offrant du confort lors de longues sessions de conduite. Le scooter est équipé d’un écran LCD qui fournit des informations importantes au conducteur, telles que la vitesse, la distance parcourue et les niveaux de carburant et d’huile.",
        price: 5000,
        imagePath: "images/moto_shop_images/Tmax.jpg",
        rate: 4,
        nbRates: 200),
    Product(
        name: "Kawasaki Ninja",
        description:
            "La Kawasaki Ninja est une moto sportive élégante et puissante qui offre une expérience de conduite exceptionnelle. Elle est équipée d’un moteur quatre cylindres en ligne de 1 000 cm³ qui produit 197 chevaux et peut atteindre une vitesse maximale de 299 km/h. ",
        price: 25000,
        imagePath: "images/moto_shop_images/kawasaki_ninja.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "BMW s1000",
        description:
            "La BMW S1000 est une moto sportive élégante et puissante qui offre une expérience de conduite exceptionnelle. Elle est équipée d’un moteur quatre cylindres en ligne de 999 cm³ qui produit 205 chevaux et peut atteindre une vitesse maximale de 299 km/h.",
        price: 18075,
        imagePath: "images/moto_shop_images/BMW_S1000.jpg",
        rate: 3,
        nbRates: 500)
  ]),
  Seller(name: "prestige meubles", products: [
    Product(
        name: "chaise",
        description:
            "Cette chaise est un meuble élégant et confortable qui offre une expérience d'assise exceptionnelle. Il est fabriqué à partir de matériaux de qualité qui respecte l'environnement",
        price: 80,
        imagePath: "images/prestige_meubles_images/chaise.jpg",
        rate: 4,
        nbRates: 200),
    Product(
        name: "lit",
        description:
            " Ce lit est un meuble élégant et confortable qui offre une expérience de sommeil exceptionnelle. Il est fabriqué à partir de matériaux de haute qualité et est disponible en plusieurs tailles. Le lit est équipé d’un sommier à lattes robuste et d’un matelas confortable, offrant un soutien optimal pour le dos et le cou. Il est recommandé de changer de matelas tous les 10 ans pour garantir un sommeil de qualité.",
        price: 520,
        imagePath: "images/prestige_meubles_images/lit.jpg",
        rate: 5,
        nbRates: 15),
    Product(
        name: "table",
        description:
            "Cette table est un meuble élégant et fonctionnel qui peut être utilisé dans n’importe quelle pièce de la maison. Elle est fabriquée à partir de matériaux de haute qualité et est disponible en plusieurs tailles et styles. La table est équipée d’un plateau spacieux et d’une base solide, offrant un espace de travail ou de rangement pratique pour les livres, les ordinateurs portables, les décorations, etc.",
        price: 288,
        imagePath: "images/prestige_meubles_images/table.jpg",
        rate: 3,
        nbRates: 500)
  ]),
];
