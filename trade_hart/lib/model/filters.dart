import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/model/setting.dart';

List<String> retrieveSubfilters(
    Map<String, List<String>> filters, String keyWord) {
  List<String> subfilters = filters.keys.where((filter) {
    return filters[filter]!.any((hashtag) {
      return hashtag
          .trim()
          .toLowerCase()
          .contains(keyWord.trim().toLowerCase());
    });
  }).toList();

  if (subfilters.isEmpty) {
    return [''];
  }

  if (subfilters.length >= 16) {
    return subfilters.sublist(0, 16);
  }
  return subfilters;
}

Map<Setting, List<String>> articlesFilters = {
  Setting(title: 'Électronique', icon: CupertinoIcons.device_laptop): [
    'Téléphones et accessoires',
    'Ordinateurs et accessoires',
    'Appareils photo et équipements photo',
    'Audio et casques',
    'Objets connectés',
    'Montres intelligentes',
    'TV et accessoires',
    'Imprimantes et scanners',
    'Accessoires électroniques',
    'Instruments de musique électroniques',
    'Gadgets et accessoires USB',
    'Cartes mémoire et stockage',
    'Pièces de rechange électroniques',
    'Appareils de réalité virtuelle',
    'Drones et accessoires'
  ],
  Setting(title: 'Vêtements et accessoires', icon: CupertinoIcons.bag): [
    'Vêtements pour hommes',
    'Vêtements pour femmes',
    'Chaussures',
    'Sacs et bagages',
    'Bijoux et montres',
    'Lunettes de soleil',
    'Chapeaux et casquettes',
    'Écharpes et foulards',
    'CeinturesGants et mitaines',
    'Costumes et vêtements formels',
    'Vêtements de sport',
    'Vêtements pour enfants'
  ],
  Setting(title: 'Maison et jardin', icon: CupertinoIcons.house): [
    'Meubles',
    'Décoration intérieure',
    'Cuisine et salle à manger',
    'Literie et linge de maison',
    'Électroménager',
    'Outils de cuisine',
    'Accessoires de salle de bain',
    'Mobilier de jardin',
    'Outils de jardinage',
    'Éclairage intérieur',
    'Éclairage extérieur',
    'Rangement et organisation',
    'Tapis et moquettes',
    'Objets de collection',
    'Produits de nettoyage domestique'
  ],
  Setting(title: 'Livres et fournitures de bureau', icon: CupertinoIcons.book):
      [
    'Livres',
    'Liseuses et tablettes',
    'Fournitures de bureau',
    'Stylos et crayons',
    'Carnets et cahiers',
    'Marqueurs et surligneurs',
    'Matériel d\'écriture artistique',
    'Organiseurs et planificateurs',
    'Correcteurs et gommes',
    'Étuis et sacs pour ordinateurs portables',
    'Accessoires de bureau',
    'Fournitures d\'art',
    'Papeterie pour enfants',
    'Instruments de mesure et de traçage'
  ],
  Setting(title: 'Sports et loisirs', icon: CupertinoIcons.sportscourt): [
    'Équipements de sport',
    'Vêtements de sport',
    'Chaussures de sport',
    'Sacs de sport',
    'Accessoires de fitness',
    'Camping et randonnée',
    'Pêche',
    'Cyclisme',
    'Natation',
    'Équipement de yoga et de pilates',
    'Équipement de musculation',
    'Sports d\'équipe',
    'Sports d\'eau',
    'Sports d\'hiver'
        'Jeux de plein air'
  ],
  Setting(title: 'Beauté et bien-être', icon: CupertinoIcons.heart): [
    'Maquillage',
    'Soins de la peau',
    'Parfums',
    'Produits de bien-être',
  ],
  Setting(title: 'Jouets et jeux', icon: CupertinoIcons.gamecontroller): [
    'Jouets pour enfants',
    'Jeux de société',
    'Jouets éducatifs',
  ],
  Setting(title: 'Automobile et moto', icon: CupertinoIcons.car_detailed): [
    'Pièces détachées',
    'Accessoires intérieurs',
    'Accessoires extérieurs',
  ],
  Setting(title: 'Instruments de musique', icon: CupertinoIcons.music_note): [
    'Guitares',
    'Claviers et pianos',
    'Instruments à vent',
  ],
  Setting(title: 'Santé et soins médicaux', icon: CupertinoIcons.staroflife): [
    'Équipements médicaux',
    'Soins personnels',
    'Produits pharmaceutiques',
  ],
  Setting(title: 'Art et artisanat', icon: CupertinoIcons.paintbrush): [
    'Peinture et dessin',
    'Sculpture',
    'Art textile',
  ],
  Setting(title: 'Alimentation et boissons', icon: Icons.food_bank_outlined): [
    'Aliments secs',
    'Produits frais',
    'Produits surgelés',
  ],
  Setting(title: 'Articles de collection', icon: CupertinoIcons.star): [
    'Monnaies et billets',
    'Timbres',
    'Cartes à collectionner',
  ],
  Setting(title: 'Technologie wearable', icon: Icons.watch): [
    'Montres intelligentes',
    'Bracelets connectés',
    'Lunettes intelligentes',
  ],
};

Map<Setting, List<String>> serviceFilters = {
  Setting(title: 'Services professionnels', icon: CupertinoIcons.briefcase): [
    'Consultation et conseil',
    'Services juridiques',
    'Services financiers',
    'Ressources humaines',
    'Traduction et interprétation',
    'Marketing et publicité',
    'Services informatiques',
    'Gestion de projet',
  ],
  Setting(title: 'Design et Créativité', icon: Icons.brush): [
    'Design graphique',
    'Illustration et animation',
    'Design de produit',
    'Photographie',
    'Vidéo et montage',
    'Musique et audio',
    'Design d\'intérieur',
    'Conception de mode',
  ],
  Setting(title: 'Rédaction et Traduction', icon: CupertinoIcons.book): [
    'Rédaction de contenu',
    'Correction et relecture',
    'Rédaction technique',
    'Rédaction créative',
    'Traduction générale',
    'Traduction spécialisée',
    'Édition et révision',
    'Rédaction académique',
  ],
  Setting(
      title: 'Développement Web et Technologique',
      icon: CupertinoIcons.device_laptop): [
    'Développement web frontend',
    'Développement web backend',
    'Développement d\'applications mobiles',
    'Développement logiciel',
    'Intégration et automatisation',
    'Sécurité informatique',
    'Administration de bases de données',
    'Analyse de données et Business Intelligence',
  ],
  Setting(title: 'Enseignement et Formation', icon: Icons.school): [
    'Cours particuliers',
    'Formation en ligne',
    'Coaching professionnel',
    'Tutorat académique',
    'Développement personnel',
    'Formation en entreprise',
    'Préparation aux examens',
    'Cours de langue',
  ],
  Setting(title: 'Services de Santé et Bien-être', icon: CupertinoIcons.heart):
      [
    'Consultation médicale en ligne',
    'Coaching de santé et bien-être',
    'Services de nutrition',
    'Thérapie physique',
    'Soins de beauté et esthétique',
    'Services de relaxation',
    'Pratiques alternatives de santé',
    'Conseils en santé mentale',
  ],
  Setting(title: 'Services Domestiques', icon: CupertinoIcons.home): [
    'Entretien ménager',
    'Jardinage et aménagement paysager',
    'Réparation et maintenance domestique',
    'Services de déménagement',
    'Garde d\'enfants',
    'Soins aux animaux domestiques',
    'Services de nettoyage de véhicules',
    'Organisation d\'événements domestiques',
  ],
  Setting(
      title: 'Consultation en Carrière et Emploi',
      icon: CupertinoIcons.person_2): [
    'Coaching en développement professionnel',
    'Services de rédaction de CV',
    'Préparation aux entretiens d\'embauche',
    'Conseils en gestion de carrière',
    'Évaluation de compétences',
    'Orientation professionnelle',
    'Services de recrutement',
    'Formation en leadership et en gestion',
  ],
  Setting(
      title: 'Services de Divertissement et Événementiel',
      icon: CupertinoIcons.star): [
    'Animation et divertissement pour événements',
    'Organisation d\'événements spéciaux',
    'Services de DJ et musique live',
    'Planification de mariage',
    'Services de photographie événementielle',
    'Services de restauration et traiteur',
    'Location de matériel événementiel',
    'Services de décoration événementielle',
  ],
  Setting(title: 'Logistique et Transport', icon: CupertinoIcons.car): [
    'Services de livraison express',
    'Transport de marchandises',
    'Déménagement professionnel',
    'Location de véhicules',
    'Services de stockage et entreposage',
    'Logistique d\'événements',
    'Transport de personnes',
    'Services de déménagement international',
  ],
};

Map<String, List<String>> articleHashtags = {
  'Téléphones et accessoires': [
    'téléphone',
    'smartphone',
    'accessoire téléphone',
    'coque',
    'chargeur',
    'écouteurs',
    'mobile'
  ],
  'Ordinateurs et accessoires': [
    'ordinateur',
    'laptop',
    'pc',
    'accessoire ordinateur',
    'clavier',
    'souris',
    'écran',
    'pc portable'
  ],
  'Appareils photo et équipements photo': [
    'appareil photo',
    'photographie',
    'objectif',
    'caméra',
    'trépied',
    'éclairage',
    'photo'
  ],
  'Audio et casques': [
    'audio',
    'casque',
    'écouteurs',
    'haut-parleur',
    'enceinte',
    'musique',
    'son'
  ],
  'Objets connectés': [
    'objets connectés',
    'smart home',
    'domotique',
    'iot',
    'internet des objets',
    'maison intelligente'
  ],
  'TV et accessoires': [
    'tv',
    'télévision',
    'écran plat',
    'home cinéma',
    'télécommande',
    'accessoire tv'
  ],
  'Imprimantes et scanners': [
    'imprimante',
    'scanner',
    'multifonction',
    'copieur',
    'impression',
    'numérisation',
    'imprimante 3d'
  ],
  'Accessoires électroniques': [
    'accessoire électronique',
    'chargeur',
    'câble',
    'adaptateur',
    'protection',
    'batterie'
  ],
  'Instruments de musique électroniques': [
    'instruments de musique',
    'instrument électronique',
    'synthétiseur',
    'clavier',
    'boîte à rythmes',
    'sampler',
    'dj'
  ],
  'Gadgets et accessoires USB': [
    'gadget',
    'accessoire usb',
    'clé usb',
    'hub usb',
    'ventilateur usb',
    'lampe usb',
    'mini frigo usb'
  ],
  'Cartes mémoire et stockage': [
    'carte mémoire',
    'stockage',
    'clé usb',
    'ssd',
    'hdd',
    'disque dur',
    'mémoire'
  ],
  'Pièces de rechange électroniques': [
    'pièces de rechange',
    'composants électroniques',
    'circuit imprimé',
    'réparation',
    'maintenance'
  ],
  'Appareils de réalité virtuelle': [
    'réalité virtuelle',
    'vr',
    'casque vr',
    'vr headset',
    'jeu vr',
    'expérience immersive'
  ],
  'Drones et accessoires': [
    'drone',
    'quadricoptère',
    'uav',
    'photographie aérienne',
    'vidéo aérienne',
    'accessoire drone'
  ],
  'Vêtements pour hommes': [
    'mode homme',
    'vêtements hommes',
    't-shirts hommes',
    'chemises',
    'pantalons hommes',
    'vêtements décontractés'
  ],
  'Vêtements pour femmes': [
    'mode femme',
    'vêtements femmes',
    'robes',
    'jupes',
    'tops femmes',
    'blouses',
    'vêtements chic'
  ],
  'Chaussures': [
    'chaussures',
    'baskets',
    'talons',
    'chaussures de sport',
    'sandales',
    'boots',
    'chaussures tendance'
  ],
  'Sacs et bagages': [
    'sacs',
    'sacs à main',
    'bagages',
    'valises',
    'sacs à dos',
    'sacs de voyage',
    'sacs en cuir'
  ],
  'Bijoux et montres': [
    'bijoux',
    'montres',
    'bracelets',
    'colliers',
    'bagues',
    'boucles d\'oreilles',
    'bijoux tendance'
  ],
  'Lunettes de soleil': [
    'lunettes de soleil',
    'lunettes',
    'accessoires de mode',
    'protection solaire',
    'lunettes tendance'
  ],
  'Chapeaux et casquettes': [
    'chapeaux',
    'casquettes',
    'bonnets',
    'bérets',
    'accessoires de tête',
    'style urbain',
    'chapeaux élégants'
  ],
  'Écharpes et foulards': [
    'écharpes',
    'foulards',
    'accessoires de mode',
    'écharpes en laine',
    'foulards en soie',
    'accessoires hiver'
  ],
  'CeinturesGants et mitaines': [
    'ceintures',
    'gants',
    'mitaines',
    'accessoires',
    'ceintures en cuir',
    'gants en laine',
    'mode hivernale'
  ],
  'Costumes et vêtements formels': [
    'costumes',
    'vêtements formels',
    'costumes hommes',
    'costumes femmes',
    'tenue de soirée',
    'smoking',
    'vêtements de bureau'
  ],
  'Meubles': [
    'meubles',
    'canapés',
    'chaises',
    'tables',
    'rangement',
    'mobilier',
    'décoration intérieure'
  ],
  'Décoration intérieure': [
    'décoration intérieure',
    'art mural',
    'objets décoratifs',
    'vases',
    'coussins',
    'rideaux',
    'design intérieur'
  ],
  'Cuisine et salle à manger': [
    'cuisine',
    'salle à manger',
    'vaisselle',
    'ustensiles de cuisine',
    'casseroles',
    'plats',
    'accessoires de cuisine'
  ],
  'Literie et linge de maison': [
    'literie',
    'linge de maison',
    'draps',
    'couettes',
    'oreillers',
    'serviettes',
    'linge de bain'
  ],
  'Électroménager': [
    'électroménager',
    'réfrigérateurs',
    'lave-vaisselle',
    'micro-ondes',
    'machines à laver',
    'petit électroménager',
    'appareils de cuisine'
  ],
  'Outils de cuisine': [
    'outils de cuisine',
    'ustensiles de cuisine',
    'couteaux de cuisine',
    'robots culinaires',
    'blenders',
    'mixeurs',
    'gadgets de cuisine'
  ],
  'Accessoires de salle de bain': [
    'accessoires de salle de bain',
    'douche',
    'robinets',
    'miroirs',
    'rangements salle de bain',
    'porte-serviettes',
    'décoration salle de bain'
  ],
  'Mobilier de jardin': [
    'mobilier de jardin',
    'chaises de jardin',
    'tables de jardin',
    'parasols',
    'balancelles',
    'salons de jardin',
    'décoration extérieure'
  ],
  'Outils de jardinage': [
    'outils de jardinage',
    'tondeuses',
    'sécateurs',
    'pelles',
    'arrosoirs',
    'jardin',
    'entretien jardin'
  ],
  'Éclairage intérieur': [
    'éclairage intérieur',
    'lampes',
    'lampadaires',
    'éclairage LED',
    'luminaires',
    'appliques murales',
    'décoration lumineuse'
  ],
  'Éclairage extérieur': [
    'éclairage extérieur',
    'luminaires extérieurs',
    'guirlandes lumineuses',
    'projecteurs',
    'appliques extérieures',
    'jardin lumineux',
    'sécurité extérieure'
  ],
  'Rangement et organisation': [
    'rangement',
    'organisation',
    'boîtes de rangement',
    'étagères',
    'armoires',
    'penderies',
    'bacs de rangement'
  ],
  'Tapis et moquettes': [
    'tapis',
    'moquettes',
    'tapis d\'intérieur',
    'tapis d\'extérieur',
    'tapis de salon',
    'tapis de chambre',
    'décoration de sol'
  ],
  'Objets de collection': [
    'objets de collection',
    'art',
    'antiquités',
    'pièces rares',
    'figurines',
    'souvenirs',
    'objets décoratifs'
  ],
  'Produits de nettoyage domestique': [
    'produits de nettoyage',
    'nettoyage maison',
    'entretien ménager',
    'désinfectants',
    'éponges',
    'produits écologiques',
    'nettoyage quotidien'
  ],
  'Livres': [
    'livres',
    'lecture',
    'romans',
    'non-fiction',
    'éducation',
    'littérature',
    'bibliothèque'
  ],
  'Liseuses et tablettes': [
    'liseuses',
    'tablettes',
    'ebooks',
    'lecture numérique',
    'kindle',
    'ebooks reader',
    'lecteurs numériques'
  ],
  'Fournitures de bureau': [
    'fournitures de bureau',
    'papeterie',
    'bureau',
    'matériel de bureau',
    'fournitures d\'écriture',
    'organisation',
    'équipements de bureau'
  ],
  'Stylos et crayons': [
    'stylos',
    'crayons',
    'écriture',
    'papeterie',
    'stylos bille',
    'stylos plume',
    'fournitures scolaires'
  ],
  'Carnets et cahiers': [
    'carnets',
    'cahiers',
    'journal',
    'bloc-notes',
    'papeterie',
    'écriture',
    'organisation'
  ],
  'Marqueurs et surligneurs': [
    'marqueurs',
    'surligneurs',
    'fournitures de bureau',
    'papeterie',
    'coloration',
    'écriture',
    'organisation'
  ],
  'Matériel d\'écriture artistique': [
    'matériel d\'écriture artistique',
    'croquis',
    'dessin',
    'fusains',
    'plumes',
    'encres',
    'peinture'
  ],
  'Organiseurs et planificateurs': [
    'organiseurs',
    'planificateurs',
    'agenda',
    'planning',
    'organisation',
    'journaux',
    'gestion du temps'
  ],
  'Correcteurs et gommes': [
    'correcteurs',
    'gommes',
    'correction',
    'effaceurs',
    'fournitures scolaires',
    'bureau',
    'papeterie'
  ],
  'Étuis et sacs pour ordinateurs portables': [
    'étuis pour ordinateurs',
    'sacs pour ordinateurs',
    'protection laptop',
    'transport ordinateur',
    'sacs à dos',
    'accessoires de bureau',
    'mobilité'
  ],
  'Accessoires de bureau': [
    'accessoires de bureau',
    'organisateurs de bureau',
    'supports d\'ordinateur',
    'repose-pieds',
    'claviers',
    'souris',
    'fournitures de bureau'
  ],
  'Fournitures d\'art': [
    'fournitures d\'art',
    'peinture',
    'toiles',
    'pinceaux',
    'art',
    'créativité',
    'matériel artistique'
  ],
  'Papeterie pour enfants': [
    'papeterie pour enfants',
    'fournitures scolaires',
    'coloriage',
    'cahiers pour enfants',
    'dessin',
    'art pour enfants',
    'crayons de couleur'
  ],
  'Instruments de mesure et de traçage': [
    'instruments de mesure',
    'traçage',
    'règles',
    'compas',
    'équerres',
    'outils de dessin',
    'fournitures de bureau'
  ],
  'Équipements de sport': [
    'équipements de sport',
    'accessoires sportifs',
    'matériel sportif',
    'équipement sportif',
    'sport',
    'performance sportive',
    'équipement d\'entraînement'
  ],
  'Vêtements de sport': [
    'vêtements de sport',
    'tenues de sport',
    'habillement sportif',
    'maillots de sport',
    'jogging',
    'vêtements de fitness',
    'mode sportive',
    'vêtements de sport',
    'sportwear',
    't-shirts de sport',
    'leggings',
    'vêtements fitness',
    'vêtements de course'
  ],
  'Chaussures de sport': [
    'chaussures de sport',
    'baskets',
    'sneakers',
    'chaussures de running',
    'chaussures de fitness',
    'chaussures de performance',
    'footwear sportif'
  ],
  'Sacs de sport': [
    'sacs de sport',
    'sacs de gym',
    'sacs de sport pour hommes',
    'sacs de sport pour femmes',
    'bagages de sport',
    'accessoires de transport',
    'sacs de voyage sportif'
  ],
  'Accessoires de fitness': [
    'accessoires de fitness',
    'équipement de fitness',
    'accessoires d\'entraînement',
    'matériel de fitness',
    'accessoires de gym',
    'fitness',
    'outils de workout'
  ],
  'Camping et randonnée': [
    'camping',
    'randonnée',
    'équipement de camping',
    'matériel de randonnée',
    'aventure en plein air',
    'accessoires de camping',
    'voyages en nature'
  ],
  'Pêche': [
    'pêche',
    'matériel de pêche',
    'accessoires de pêche',
    'canne à pêche',
    'appâts',
    'équipement de pêche',
    'sports de pêche'
  ],
  'Cyclisme': [
    'cyclisme',
    'vélo',
    'accessoires de vélo',
    'équipement de cyclisme',
    'vêtements de cyclisme',
    'réparation de vélo',
    'sports de cyclisme'
  ],
  'Natation': [
    'natation',
    'maillots de bain',
    'équipements de natation',
    'accessoires de natation',
    'bain',
    'plongée',
    'sports aquatiques'
  ],
  'Équipement de yoga et de pilates': [
    'équipement de yoga',
    'équipement de pilates',
    'tapis de yoga',
    'accessoires de yoga',
    'matériel de pilates',
    'yoga',
    'pilates'
  ],
  'Équipement de musculation': [
    'équipement de musculation',
    'haltères',
    'machines de musculation',
    'accessoires de musculation',
    'exercices de musculation',
    'salle de gym',
    'fitness'
  ],
  'Sports d\'équipe': [
    'sports d\'équipe',
    'football',
    'basketball',
    'rugby',
    'volleyball',
    'sports collectifs',
    'activités de groupe'
  ],
  'Sports d\'eau': [
    'sports d\'eau',
    'surf',
    'planche à voile',
    'canoë',
    'kayak',
    'sports nautiques',
    'activités aquatiques'
  ],
  'Sports d\'hiver': [
    'sports d\'hiver',
    'ski',
    'snowboard',
    'patinage',
    'raquettes',
    'sports de neige',
    'activités hivernales'
  ],
  'Jeux de plein air': [
    'jeux de plein air',
    'activités en extérieur',
    'jeux en famille',
    'sports en plein air',
    'jeux de société extérieurs',
    'activités récréatives',
    'loisirs en plein air'
  ],
  'Maquillage': [
    'maquillage',
    'cosmétiques',
    'makeup',
    'maquillage de jour',
    'maquillage de nuit',
    'produits de beauté',
    'fond de teint',
    'rouge à lèvres',
    'mascara'
  ],
  'Soins de la peau': [
    'soins de la peau',
    'soin du visage',
    'crème hydratante',
    'nettoyant',
    'exfoliant',
    'masque facial',
    'soin anti-âge',
    'routine de beauté',
    'soins de la peau'
  ],
  'Parfums': [
    'parfums',
    'fragrances',
    'eau de toilette',
    'eau de parfum',
    'colognes',
    'parfum pour hommes',
    'parfum pour femmes',
    'scents',
    'odeur'
  ],
  'Produits de bien-être': [
    'produits de bien-être',
    'bien-être',
    'compléments alimentaires',
    'produits naturels',
    'aromathérapie',
    'huiles essentielles',
    'relaxation',
    'santé'
  ],
  'Jouets pour enfants': [
    'jouets enfants',
    'jouets',
    'jeux enfants',
    'jouets éducatifs',
    'jeux pour bébés',
    'jouets interactifs',
    'jeux d\'imitation',
    'jouets créatifs'
  ],
  'Jeux de société': [
    'jeux de société',
    'jeux de table',
    'jeux de plateau',
    'jeux en famille',
    'jeux de stratégie',
    'jeux de cartes',
    'jeux d\'amusement',
    'jeux de réflexion'
  ],
  'Jouets éducatifs': [
    'jouets éducatifs',
    'apprentissage par le jeu',
    'jeux éducatifs',
    'jouets stimulants',
    'jeux pédagogiques',
    'jouets pour apprendre',
    'éducation des enfants',
    'jeux d\'apprentissage'
  ],
  'Pièces détachées': [
    'pièces détachées',
    'réparations',
    'accessoires',
    'pièces de rechange',
    'composants',
    'réparation appareils',
    'maintenance',
    'réparation électronique'
  ],
  'Accessoires intérieurs': [
    'accessoires intérieurs',
    'décoration intérieure',
    'accessoires maison',
    'décor',
    'objets décoratifs',
    'accessoires de décoration',
    'mobilier intérieur',
    'aménagement intérieur'
  ],
  'Accessoires extérieurs': [
    'accessoires extérieurs',
    'décoration extérieure',
    'mobilier de jardin',
    'accessoires de jardin',
    'aménagement extérieur',
    'objets extérieurs',
    'décor de jardin',
    'équipements extérieurs'
  ],
  'Guitares': [
    'guitares',
    'guitares électriques',
    'guitares acoustiques',
    'instruments à cordes',
    'guitaristes',
    'accessoires pour guitare',
    'musique',
    'guitar learning'
  ],
  'Claviers et pianos': [
    'claviers',
    'pianos',
    'instruments de musique',
    'claviers électroniques',
    'pianos numériques',
    'accessoires pour pianos',
    'musique',
    'cours de piano'
  ],
  'Instruments à vent': [
    'instruments à vent',
    'clarinettes',
    'saxophones',
    'flûtes',
    'trompettes',
    'musique',
    'instruments de musique',
    'vent instruments'
  ],
  'Équipements médicaux': [
    'équipements médicaux',
    'matériel médical',
    'appareils médicaux',
    'diagnostic',
    'traitement médical',
    'soins médicaux',
    'équipements de santé',
    'dispositifs médicaux'
  ],
  'Soins personnels': [
    'soins personnels',
    'hygiène',
    'soins corporels',
    'produits de soin',
    'bien-être',
    'routine de soins',
    'soins quotidiens',
    'soins du corps'
  ],
  'Produits pharmaceutiques': [
    'produits pharmaceutiques',
    'médicaments',
    'pharmacie',
    'produits médicaux',
    'prescriptions',
    'santé',
    'soins médicaux',
    'produits de santé'
  ],
  'Peinture et dessin': [
    'peinture',
    'dessin',
    'art',
    'matériel de peinture',
    'fournitures de dessin',
    'techniques artistiques',
    'création artistique',
    'peinture artistique'
  ],
  'Sculpture': [
    'sculpture',
    'art',
    'création de sculptures',
    'sculptures en bois',
    'sculptures en métal',
    'œuvres d\'art',
    'sculpture moderne',
    'techniques de sculpture'
  ],
  'Art textile': [
    'art textile',
    'broderie',
    'tricot',
    'tissage',
    'créations textiles',
    'artisanat',
    'projets textiles',
    'matériaux pour textile'
  ],
  'Aliments secs': [
    'aliments secs',
    'denrées non périssables',
    'produits secs',
    'céréales',
    'pâtes',
    'riz',
    'snacks secs',
    'aliments emballés'
  ],
  'Produits frais': [
    'produits frais',
    'fruits',
    'légumes',
    'produits laitiers',
    'viandes fraîches',
    'produits du marché',
    'aliments sains',
    'achats frais'
  ],
  'Produits surgelés': [
    'produits surgelés',
    'aliments congelés',
    'congélateurs',
    'plats préparés',
    'surgelés',
    'aliments prêts à cuire',
    'surgelés de fruits',
    'surgelés de légumes'
  ],
  'Monnaies et billets': [
    'monnaies',
    'billets',
    'collections',
    'numismatique',
    'pièces de monnaie',
    'billets de banque',
    'monnaies rares',
    'numismatique collection'
  ],
  'Timbres': [
    'timbres',
    'philatélie',
    'collections de timbres',
    'timbres rares',
    'timbres anciens',
    'timbres de collection',
    'postage stamps',
    'philatelic collection'
  ],
  'Cartes à collectionner': [
    'cartes à collectionner',
    'cartes de jeux',
    'cartes de collection',
    'trading cards',
    'cartes rares',
    'cartes de sports',
    'cartes de jeux vidéo',
    'collection de cartes'
  ],
  'Montres intelligentes': [
    'montres intelligentes',
    'smartwatches',
    'technologie wearable',
    'montres connectées',
    'accessoires technologiques',
    'montres de fitness',
    'suivi de santé',
    'montres intelligentes'
  ],
  'Bracelets connectés': [
    'bracelets connectés',
    'fitness trackers',
    'bracelets de santé',
    'technologie wearable',
    'suivi d\'activité',
    'bracelets intelligents',
    'moniteurs de fitness',
    'bracelets pour le bien-être'
  ],
  'Lunettes intelligentes': [
    'lunettes intelligentes',
    'smart glasses',
    'technologie wearable',
    'réalité augmentée',
    'lunettes connectées',
    'innovation technologique',
    'lunettes avec écran',
    'smart eyewear'
  ],
};

Map<String, List<String>> serviceHashtags = {
  'Consultation et conseil': [
    'consultation',
    'conseil',
    'services de conseil',
    'consultant',
    'stratégie',
    'services professionnels',
    'consultation d\'expert',
    'conseils professionnels'
  ],
  'Services juridiques': [
    'services juridiques',
    'avocat',
    'conseil juridique',
    'droit',
    'juridique',
    'assistance légale',
    'services de droit',
    'avocat conseil'
  ],
  'Services financiers': [
    'services financiers',
    'conseil financier',
    'gestion de patrimoine',
    'planification financière',
    'services bancaires',
    'conseil en investissement',
    'gestion financière',
    'services de comptabilité'
  ],
  'Ressources humaines': [
    'ressources humaines',
    'RH',
    'gestion du personnel',
    'recrutement',
    'développement des talents',
    'gestion des employés',
    'services RH',
    'gestion des ressources humaines'
  ],
  'Traduction et interprétation': [
    'traduction',
    'interprétation',
    'services de traduction',
    'traduction professionnelle',
    'traduction spécialisée',
    'services d\'interprétation',
    'traduction linguistique',
    'interprétation simultanée'
  ],
  'Marketing et publicité': [
    'marketing',
    'publicité',
    'stratégies de marketing',
    'campagnes publicitaires',
    'publicité numérique',
    'marketing de contenu',
    'gestion de marque',
    'publicité en ligne'
  ],
  'Services informatiques': [
    'services informatiques',
    'IT',
    'support technique',
    'consultation IT',
    'gestion des systèmes',
    'services de réseau',
    'développement IT',
    'maintenance informatique'
  ],
  'Gestion de projet': [
    'gestion de projet',
    'project management',
    'planification de projet',
    'exécution de projet',
    'suivi de projet',
    'gestion des ressources',
    'gestion des équipes',
    'méthodologie de projet'
  ],
  'Design graphique': [
    'design graphique',
    'graphisme',
    'création graphique',
    'design visuel',
    'design de marque',
    'identité visuelle',
    'design de logo',
    'graphisme créatif'
  ],
  'Illustration et animation': [
    'illustration',
    'animation',
    'design animé',
    'illustrations numériques',
    'animation 2D',
    'animation 3D',
    'art visuel',
    'illustrations créatives'
  ],
  'Design de produit': [
    'design de produit',
    'conception de produit',
    'design industriel',
    'innovation produit',
    'prototype',
    'développement produit',
    'création de produit',
    'design produit'
  ],
  'Photographie': [
    'photographie',
    'photo',
    'prise de vue',
    'art photographique',
    'photo professionnelle',
    'techniques de photographie',
    'photographie numérique',
    'portraits'
  ],
  'Vidéo et montage': [
    'vidéo',
    'montage vidéo',
    'édition vidéo',
    'production vidéo',
    'vidéographie',
    'montage',
    'création de vidéos',
    'vidéo professionnelle'
  ],
  'Musique et audio': [
    'musique',
    'audio',
    'production musicale',
    'enregistrement audio',
    'son',
    'musique professionnelle',
    'techniques audio',
    'équipements audio'
  ],
  'Design d\'intérieur': [
    'design d\'intérieur',
    'aménagement intérieur',
    'décoration intérieure',
    'architecture intérieure',
    'design de maison',
    'projets d\'intérieur',
    'design moderne',
    'décor intérieur'
  ],
  'Conception de mode': [
    'conception de mode',
    'mode',
    'design de vêtements',
    'création de mode',
    'tendances de mode',
    'fashion design',
    'collection de mode',
    'créateurs de mode'
  ],
  'Rédaction de contenu': [
    'rédaction de contenu',
    'copywriting',
    'création de contenu',
    'rédaction professionnelle',
    'contenu marketing',
    'rédaction SEO',
    'rédaction web',
    'content writing'
  ],
  'Correction et relecture': [
    'correction',
    'relecture',
    'révision',
    'édition',
    'vérification de texte',
    'services de relecture',
    'amélioration de texte',
    'correction d\'épreuves'
  ],
  'Rédaction technique': [
    'rédaction technique',
    'documentation technique',
    'rédaction professionnelle',
    'manuels utilisateurs',
    'rédaction spécialisée',
    'instructions',
    'guides techniques',
    'rédaction technique'
  ],
  'Rédaction créative': [
    'rédaction créative',
    'écriture créative',
    'content creation',
    'écriture imaginative',
    'rédaction originale',
    'rédaction artistique',
    'créativité',
    'écrivain'
  ],
  'Traduction générale': [
    'traduction générale',
    'services de traduction',
    'traduction linguistique',
    'traduction de texte',
    'traduction professionnelle',
    'traduction multi-langues',
    'services linguistiques',
    'traduction'
  ],
  'Traduction spécialisée': [
    'traduction spécialisée',
    'traduction technique',
    'traduction médicale',
    'traduction juridique',
    'traduction scientifique',
    'traduction spécialisée',
    'services de traduction',
    'expertise linguistique'
  ],
  'Édition et révision': [
    'édition',
    'révision',
    'correction de texte',
    'services d\'édition',
    'révision de manuscrit',
    'amélioration de texte',
    'éditer',
    'révision professionnelle'
  ],
  'Rédaction académique': [
    'rédaction académique',
    'écriture académique',
    'essais',
    'thèses',
    'rapports de recherche',
    'articles scientifiques',
    'rédaction universitaire',
    'rédaction de recherche'
  ],
  'Développement web frontend': [
    'développement web frontend',
    'frontend',
    'design web',
    'développement d\'interface utilisateur',
    'HTML',
    'CSS',
    'JavaScript',
    'développement web'
  ],
  'Développement web backend': [
    'développement web backend',
    'backend',
    'serveur',
    'bases de données',
    'API',
    'programmation serveur',
    'technologies backend',
    'développement backend'
  ],
  'Développement d\'applications mobiles': [
    'développement d\'applications mobiles',
    'applications Android',
    'applications iOS',
    'développement mobile',
    'programmes mobiles',
    'applications mobiles',
    'techniques de développement mobile',
    'app development'
  ],
  'Développement logiciel': [
    'développement logiciel',
    'programmation',
    'logiciels',
    'développement de logiciels',
    'ingénierie logicielle',
    'création de logiciels',
    'développement de systèmes',
    'software development'
  ],
  'Intégration et automatisation': [
    'intégration',
    'automatisation',
    'systèmes intégrés',
    'processus automatisés',
    'intégration de systèmes',
    'automatisation des tâches',
    'solutions d\'intégration',
    'technologie d\'automatisation'
  ],
  'Sécurité informatique': [
    'sécurité informatique',
    'cybersécurité',
    'protection des données',
    'sécurité des systèmes',
    'gestion des risques',
    'sécurité réseau',
    'sécurité IT',
    'data security'
  ],
  'Administration de bases de données': [
    'administration de bases de données',
    'DBA',
    'gestion de bases de données',
    'systèmes de bases de données',
    'SQL',
    'optimisation des bases de données',
    'administration de données',
    'database management'
  ],
  'Analyse de données et Business Intelligence': [
    'analyse de données',
    'Business Intelligence',
    'BI',
    'data analysis',
    'visualisation des données',
    'rapports analytiques',
    'gestion des données',
    'analyse business'
  ],
  'Cours particuliers': [
    'cours particuliers',
    'tutorat',
    'enseignement individuel',
    'leçons privées',
    'cours de soutien',
    'éducation personnalisée',
    'aide scolaire',
    'formation individuelle'
  ],
  'Formation en ligne': [
    'formation en ligne',
    'e-learning',
    'cours en ligne',
    'éducation à distance',
    'programmes de formation',
    'cours virtuels',
    'apprentissage en ligne',
    'formation digitale'
  ],
  'Coaching professionnel': [
    'coaching professionnel',
    'développement de carrière',
    'mentorat',
    'accompagnement professionnel',
    'coaching de carrière',
    'développement personnel',
    'formation en entreprise',
    'coaching'
  ],
  'Tutorat académique': [
    'tutorat académique',
    'aide aux devoirs',
    'tuteur',
    'soutien scolaire',
    'assistance académique',
    'cours de rattrapage',
    'tutorat en ligne',
    'aide à l\'étude'
  ],
  'Développement personnel': [
    'développement personnel',
    'croissance personnelle',
    'bien-être',
    'coaching personnel',
    'compétences personnelles',
    'épanouissement',
    'formation personnelle',
    'développement'
  ],
  'Formation en entreprise': [
    'formation en entreprise',
    'formation professionnelle',
    'développement des compétences',
    'formation interne',
    'sessions de formation',
    'ateliers en entreprise',
    'formation continue',
    'formation des employés'
  ],
  'Préparation aux examens': [
    'préparation aux examens',
    'révision',
    'aide aux examens',
    'coaching pour examens',
    'matériel de révision',
    'préparation académique',
    'stratégies d\'examen',
    'conseils pour examens'
  ],
  'Cours de langue': [
    'cours de langue',
    'apprentissage des langues',
    'leçons de langue',
    'tutorat linguistique',
    'formation linguistique',
    'cours de conversation',
    'éducation linguistique',
    'langues étrangères'
  ],
  'Consultation médicale en ligne': [
    'consultation médicale en ligne',
    'téléconsultation',
    'médecine en ligne',
    'soins à distance',
    'conseils médicaux',
    'consultation virtuelle',
    'médecin en ligne',
    'télémedecine'
  ],
  'Coaching de santé et bien-être': [
    'coaching de santé',
    'bien-être',
    'coaching personnel',
    'santé holistique',
    'accompagnement santé',
    'développement personnel',
    'coaching de vie',
    'pratiques de bien-être'
  ],
  'Services de nutrition': [
    'services de nutrition',
    'consultation nutritionnelle',
    'plan de nutrition',
    'conseils diététiques',
    'nutrition saine',
    'services diététiques',
    'alimentation équilibrée',
    'plan nutritionnel'
  ],
  'Thérapie physique': [
    'thérapie physique',
    'réhabilitation',
    'physiothérapie',
    'soins de réhabilitation',
    'rééducation physique',
    'thérapeute',
    'exercices de réhabilitation',
    'physiotherapist'
  ],
  'Soins de beauté et esthétique': [
    'soins de beauté',
    'esthétique',
    'services de beauté',
    'soins de la peau',
    'soins capillaires',
    'maquillage',
    'soins esthétiques',
    'soins corporels'
  ],
  'Services de relaxation': [
    'services de relaxation',
    'relaxation',
    'techniques de relaxation',
    'massage',
    'méditation',
    'pratiques de relaxation',
    'bien-être',
    'relaxation mentale'
  ],
  'Pratiques alternatives de santé': [
    'pratiques alternatives',
    'médecine alternative',
    'thérapies alternatives',
    'soins naturels',
    'médecine douce',
    'approches holistiques',
    'pratiques de bien-être',
    'alternative health'
  ],
  'Conseils en santé mentale': [
    'conseils en santé mentale',
    'psychologie',
    'thérapie',
    'bien-être mental',
    'accompagnement psychologique',
    'santé mentale',
    'conseil psychologique',
    'soutien mental'
  ],
  'Entretien ménager': [
    'entretien ménager',
    'ménage',
    'services de nettoyage',
    'nettoyage à domicile',
    'entretien de maison',
    'services ménagers',
    'nettoyage intérieur',
    'maintenance ménagère'
  ],
  'Jardinage et aménagement paysager': [
    'jardinage',
    'aménagement paysager',
    'entretien de jardin',
    'paysagisme',
    'plantes',
    'jardinage extérieur',
    'services de jardinage',
    'aménagement de jardin'
  ],
  'Réparation et maintenance domestique': [
    'réparation domestique',
    'maintenance de maison',
    'services de réparation',
    'entretien de la maison',
    'réparation à domicile',
    'services de maintenance',
    'réparation ménagère',
    'maintenance'
  ],
  'Services de déménagement': [
    'services de déménagement',
    'déménagement',
    'transport',
    'déplacement de biens',
    'services de relocalisation',
    'déménagement professionnel',
    'logistique de déménagement',
    'moving services'
  ],
  'Garde d\'enfants': [
    'garde d\'enfants',
    'babysitting',
    'services de garde',
    'crèche',
    'garderie',
    'soins d\'enfants',
    'accompagnement enfants',
    'services pour enfants'
  ],
  'Soins aux animaux domestiques': [
    'soins aux animaux',
    'animaux domestiques',
    'garde d\'animaux',
    'services pour animaux',
    'entretien animal',
    'soins pour animaux',
    'pet care',
    'animaux de compagnie'
  ],
  'Services de nettoyage de véhicules': [
    'nettoyage de véhicules',
    'lavage de voiture',
    'entretien automobile',
    'services de detailing',
    'nettoyage extérieur',
    'services de lavage',
    'soins de voiture',
    'auto detailing'
  ],
  'Organisation d\'événements domestiques': [
    'organisation d\'événements',
    'événements domestiques',
    'planification d\'événements',
    'services de gestion d\'événements',
    'organisation de fêtes',
    'planification de célébrations',
    'services événementiels',
    'events planning'
  ],
  'Coaching en développement professionnel': [
    'coaching professionnel',
    'développement de carrière',
    'mentorat',
    'coaching de carrière',
    'accompagnement professionnel',
    'formation en leadership',
    'coaching',
    'carrière professionnelle'
  ],
  'Services de rédaction de CV': [
    'rédaction de CV',
    'services de CV',
    'création de CV',
    'rédaction professionnelle',
    'aide à la recherche d\'emploi',
    'CV personnalisé',
    'rédaction de lettre de motivation',
    'résumés professionnels'
  ],
  'Préparation aux entretiens d\'embauche': [
    'préparation aux entretiens',
    'coaching entretien',
    'conseils d\'embauche',
    'simulation d\'entretien',
    'répétition d\'entretien',
    'préparation à l\'emploi',
    'entretien professionnel',
    'interview coaching'
  ],
  'Conseils en gestion de carrière': [
    'conseils en gestion de carrière',
    'planification de carrière',
    'développement de carrière',
    'accompagnement professionnel',
    'orientation professionnelle',
    'gestion de carrière',
    'coaching de carrière',
    'career advice'
  ],
  'Évaluation de compétences': [
    'évaluation de compétences',
    'tests de compétences',
    'évaluation professionnelle',
    'compétences professionnelles',
    'évaluation des talents',
    'analyse des compétences',
    'compétences clés',
    'skills assessment'
  ],
  'Orientation professionnelle': [
    'orientation professionnelle',
    'conseils de carrière',
    'plan de carrière',
    'accompagnement de carrière',
    'orientation professionnelle',
    'planification de carrière',
    'conseil en carrière',
    'career guidance'
  ],
  'Services de recrutement': [
    'services de recrutement',
    'recrutement',
    'gestion des talents',
    'embauche',
    'sélection de candidats',
    'services RH',
    'recruteur',
    'recrutement professionnel'
  ],
  'Formation en leadership et en gestion': [
    'formation en leadership',
    'gestion',
    'développement des compétences de leadership',
    'coaching en gestion',
    'formation en management',
    'leadership',
    'gestion des équipes',
    'leadership training'
  ],
  'Animation et divertissement pour événements': [
    'animation d\'événements',
    'divertissement',
    'services de divertissement',
    'animation pour événements',
    'spectacles',
    'événements',
    'services de divertissement',
    'animation'
  ],
  'Organisation d\'événements spéciaux': [
    'organisation d\'événements',
    'événements spéciaux',
    'planification d\'événements',
    'services d\'événements',
    'événements uniques',
    'gestion d\'événements',
    'événements personnalisés',
    'event planning'
  ],
  'Services de DJ et musique live': [
    'services de DJ',
    'musique live',
    'animation musicale',
    'DJ',
    'musique pour événements',
    'services musicaux',
    'DJ professionnel',
    'musique en direct'
  ],
  'Planification de mariage': [
    'planification de mariage',
    'organisation de mariage',
    'services de mariage',
    'coordination de mariage',
    'préparation de mariage',
    'mariage',
    'organisation de noces',
    'services de mariage'
  ],
  'Services de photographie événementielle': [
    'photographie événementielle',
    'services de photographie',
    'photos d\'événements',
    'photographe professionnel',
    'photos de mariage',
    'capturer des moments',
    'photographie pour événements',
    'event photography'
  ],
  'Services de restauration et traiteur': [
    'services de restauration',
    'traiteur',
    'catering',
    'services alimentaires',
    'repas pour événements',
    'menu',
    'organisation de repas',
    'cuisine événementielle'
  ],
  'Location de matériel événementiel': [
    'location de matériel',
    'matériel événementiel',
    'équipement pour événements',
    'location d\'équipements',
    'services de location',
    'matériel pour fêtes',
    'location pour événements',
    'event equipment rental'
  ],
  'Services de décoration événementielle': [
    'décoration événementielle',
    'services de décoration',
    'aménagement d\'événements',
    'décor pour fêtes',
    'design événementiel',
    'décoration',
    'services de design',
    'event decor'
  ],
  'Services de livraison express': [
    'services de livraison express',
    'livraison rapide',
    'services de transport',
    'expédition urgente',
    'livraison',
    'service de messagerie',
    'livraison en 24h',
    'express delivery'
  ],
  'Transport de marchandises': [
    'transport de marchandises',
    'logistique',
    'expédition de marchandises',
    'services de transport',
    'gestion de la chaîne d\'approvisionnement',
    'transport',
    'expédition',
    'freight transport'
  ],
  'Déménagement professionnel': [
    'déménagement professionnel',
    'services de déménagement',
    'déménagement',
    'déplacement de biens',
    'logistique de déménagement',
    'déménagement en entreprise',
    'moving services',
    'professional moving'
  ],
  'Location de véhicules': [
    'location de véhicules',
    'voiture de location',
    'services de location',
    'location de voiture',
    'location de camion',
    'transports',
    'location de véhicule',
    'car rental'
  ],
  'Services de stockage et entreposage': [
    'services de stockage',
    'entreposage',
    'stockage',
    'solutions de stockage',
    'services de self-stockage',
    'entreposage professionnel',
    'gestion de stockage',
    'storage solutions'
  ],
  'Logistique d\'événements': [
    'logistique d\'événements',
    'organisation d\'événements',
    'gestion d\'événements',
    'planification d\'événements',
    'services événementiels',
    'logistique',
    'événements',
    'event logistics'
  ],
  'Transport de personnes': [
    'transport de personnes',
    'services de transport',
    'transports privés',
    'services de navette',
    'transport',
    'location de véhicules',
    'transport personnel',
    'people transport'
  ],
  'Services de déménagement international': [
    'déménagement international',
    'services de déménagement',
    'transfert international',
    'déménagement à l\'étranger',
    'logistique internationale',
    'services de relocation',
    'international moving',
    'relocation services'
  ]
};
