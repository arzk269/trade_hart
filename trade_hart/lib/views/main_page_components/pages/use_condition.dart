import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class UseConditionsPage extends StatelessWidget {
  const UseConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Condition d'utilisation",
          style: GoogleFonts.poppins(fontSize: manageWidth(context, 17)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(manageWidth(context, 6.0)),
        child: Text(
          '''
Dernière mise à jour : 07 juin  2024

Bienvenue sur TradHart, une marketplace digitale permettant de vendre des services en ligne ou des articles. En accédant à notre site ou en utilisant nos services, vous acceptez d'être lié par les présentes Conditions d'Utilisation. Veuillez les lire attentivement avant de commencer à utiliser notre plateforme.

1. Acceptation des Conditions
En utilisant TradHart, vous acceptez les présentes Conditions d'Utilisation, notre Politique de Confidentialité, et toutes les lois et réglementations applicables. Si vous n'acceptez pas ces conditions, vous ne devez pas utiliser notre site.

2. Modifications des Conditions
TradHart se réserve le droit de modifier ces Conditions d'Utilisation à tout moment. Nous vous informerons des modifications significatives par email ou par une notification sur notre site. En continuant à utiliser notre site après la publication des modifications, vous acceptez d'être lié par les nouvelles conditions.

3. Inscription et Compte Utilisateur
3.1 Éligibilité
Pour utiliser nos services, vous devez être âgé de 18 ans ou plus et avoir la capacité juridique de conclure des contrats.

3.2 Informations de Compte
Vous devez fournir des informations exactes, complètes et à jour lors de votre inscription. Vous êtes responsable de la confidentialité de votre compte et de votre mot de passe et acceptez de nous informer immédiatement de toute utilisation non autorisée de votre compte.

3.3 Utilisation du Compte
Vous acceptez de n'utiliser votre compte qu'à des fins légales et de respecter toutes les lois et réglementations applicables.

4. Utilisation de la Plateforme
4.1 Conduite Prohibée
Vous vous engagez à ne pas :

Utiliser notre site à des fins illégales ou frauduleuses.
Soumettre des informations fausses ou trompeuses.
Violater les droits de propriété intellectuelle de tiers.
Transmettre des virus, des logiciels malveillants ou toute autre technologie nuisible.
4.2 Contenu Utilisateur
Vous êtes seul responsable du contenu que vous publiez ou mettez à disposition sur notre site. Vous garantissez que vous avez les droits nécessaires pour publier ce contenu et que celui-ci ne viole aucun droit de tiers.

5. Transactions entre Utilisateurs
5.1 Rôle de TradHart
TradHart agit comme une plateforme intermédiaire permettant aux utilisateurs de vendre et d'acheter des services et des produits. Nous ne sommes pas partie aux transactions entre acheteurs et vendeurs et n'assumons aucune responsabilité quant à la qualité, la sécurité ou la légalité des articles ou services proposés.

5.2 Frais de Livraison
Les frais de livraison sont spécifiés par les vendeurs pour chaque article individuel. Cependant, afin d'éviter des frais excessifs, les frais de livraison pour chaque commande sont plafonnés à 15% du montant total de la commande. Par exemple, pour une commande de 40 euros, les frais de livraison ne dépasseront pas 6 euros. Si les frais de livraison calculés dépassent ce plafond, le montant attribué sera ajusté en conséquence.

5.3 Frais de Transaction
Pour chaque transaction effectuée via notre plateforme, un frais de service de 13% est prélevé sur le montant total de la vente, dont environ 3% est destiné à couvrir les frais de traitement de paiement par notre prestataire, Stripe. Ces frais permettent de maintenir et d'améliorer nos services pour vous offrir la meilleure expérience possible.

5.4 Paiements
Les paiements effectués via notre plateforme sont traités par des prestataires de services de paiement tiers. Vous acceptez de respecter les conditions d'utilisation de ces prestataires.

5.5 Litiges entre Utilisateurs
En cas de litige entre utilisateurs, nous vous encourageons à tenter de résoudre le différend à l'amiable. TradHart peut, à sa discrétion, tenter de faciliter la résolution des litiges, mais n'assume aucune obligation à cet égard.

6. Propriété Intellectuelle
6.1 Droits de TradHart
Tout le contenu et les matériaux disponibles sur notre site, y compris, sans s'y limiter, les textes, graphiques, logos, icônes, images, clips audio et logiciels, sont la propriété de TradHart ou de ses fournisseurs de contenu et sont protégés par les lois sur la propriété intellectuelle.

6.2 Utilisation de la Propriété Intellectuelle
Vous ne pouvez utiliser notre contenu que pour votre usage personnel et non commercial, sauf autorisation expresse de notre part.

7. Limitation de Responsabilité
Dans toute la mesure permise par la loi, TradHart et ses affiliés, dirigeants, employés, agents, partenaires et concédants de licence ne seront pas responsables des dommages indirects, accessoires, spéciaux, consécutifs ou punitifs, ni de toute perte de revenus ou de profits, résultant de votre utilisation de notre site ou de nos services.

8. Indemnisation
Vous acceptez d'indemniser, de défendre et de dégager de toute responsabilité TradHart et ses affiliés, dirigeants, employés, agents, partenaires et concédants de licence contre toute réclamation, perte, dommage, responsabilité et coût (y compris les honoraires d'avocat raisonnables) découlant de votre utilisation de notre site ou de nos services, de votre violation de ces Conditions d'Utilisation, ou de votre violation de tout droit de tiers.

9. Résiliation
TradHart se réserve le droit de suspendre ou de résilier votre compte et votre accès à notre site à tout moment, sans préavis, en cas de violation de ces Conditions d'Utilisation ou de toute loi ou réglementation applicable.

10. Droit Applicable et Juridiction
Ces Conditions d'Utilisation sont régies et interprétées conformément aux lois, sans égard aux principes de conflit de lois. Vous acceptez de vous soumettre à la juridiction exclusive des tribunaux pour la résolution de tout litige découlant de ces Conditions d'Utilisation ou de votre utilisation de notre site.

11. Dispositions Générales
11.1 Intégralité de l'Accord
Ces Conditions d'Utilisation, ainsi que notre Politique de Confidentialité, constituent l'intégralité de l'accord entre vous et TradHart concernant l'utilisation de notre site et remplacent tous les accords antérieurs.

11.2 Divisibilité
Si une disposition de ces Conditions d'Utilisation est jugée invalide ou inapplicable, les autres dispositions resteront en vigueur.

11.3 Renonciation
Le fait pour TradHart de ne pas exercer ou faire appliquer un droit ou une disposition de ces Conditions d'Utilisation ne constitue pas une renonciation à ce droit ou à cette disposition.

12. Contact
Si vous avez des questions concernant ces Conditions d'Utilisation, veuillez nous contacter à :

TradHart
5 rue des Essarts, 45140 Saint-Jean-de-la-Ruelle, France
contact.tradhart@gmail.com
07 51 25 88 37 

Nous vous remercions d'avoir choisi TradHart. Votre confiance et votre satisfaction sont nos priorités.
          ''',
          style: GoogleFonts.poppins(fontSize: 14.0),
        ),
      ),
    );
  }
}
