/* ***********************************************************
 Pour le projet Backup de Exsitu
 Réception de messages OSC envoyés par pure data 
 Et affichage des infos tirées de la base de données en conséquence
 Quimper, Dour Ru, 7 juin 2019 / pierre@lesporteslogiques.net
 processing 3.4 @ kirin
 
 Messages transmis par pure data :
 /video/enveloppe/id (float)
 /video/enveloppe/max (float)
 /video/enveloppe/fadein (float)
 /video/enveloppe/decay (float)
 /video/enveloppe/fadeout (float)
 /video/control/color (float)
 
 Notes : 
   Il n'y a que 992 images dans le dossier des 1000 images :)
     -> le programme crée des images vides pour compléter les manquantes
     -> il manque : 14, 43, 63, 75, 88, 92, 93, 100

 *********************************************************** */

// Déclaration des objets OSC *********************************
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;

// Initialisation des variables  ******************************
float video_enveloppe_id      = 1;
float video_enveloppe_max     = 0;
float video_enveloppe_fadein  = 0;
float video_enveloppe_decay   = 0;
float video_enveloppe_fadeout = 0;
float video_control_color     = 0;

// Déclaration du tableau contenant une image par objet *******
String dossier_images = "objets-geocyclab"; // à placer dans le dossier data
PImage[] image_objet = new PImage[1001];    // 1001 pour conserver les id (un tableau est indexé à partir de 0)

// Déclaration de la base de données ***************************
String base_objets = "exsitu-backup.csv";   // à placer dans le dossier data
Table objet;

// Assets
PImage planisphere;
PShape bulle;

// Variables utilisées pour l'animation
int old_id = -1;


// Variables temporaires utilisées pour la mise au point
float plan_x, plan_y;  // Utilisées pour fixer un point au hasard sur le planisphere
float r,g,b;           // utilisées pour la couleur de la sphère

void setup() {
  
  size(1000, 750, P3D);
  
  // Mettre en place la communication OSC
  oscP5 = new OscP5(this, 8003); // écoute des messages OSC sur le port 8003
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  
  // Charger les images des 1000 objets
  chargerImages(dossier_images);
  
  planisphere = loadImage("planisphere.png"); // 480 x 290
  
  // Charger la base de données des objets
  objet = loadTable("data/" + base_objets, "header");
  println(objet.getRowCount() + " lignes dans la base"); 
  /*
  for (TableRow ligne : objet.rows()) { 
    int    o_id             = ligne.getInt("ID");
    int    o_date_jour      = ligne.getInt("Date jour");
    int    o_date_mois      = ligne.getInt("Date mois");
    int    o_date_annee     = ligne.getInt("Date année");
    String o_date           = o_date_jour + "/" + o_date_mois + "/" + o_date_annee;
    String o_depart         = ligne.getString("Départ");
    String o_arrivee        = ligne.getString("Arrivée");
    String o_pays           = ligne.getString("Pays");
    int    o_km             = ligne.getInt("KMs jour");
    int    o_km_cumul       = ligne.getInt("KMs cumulé");
    int    o_altitude       = ligne.getInt("Altitude (m)");
    int    o_lat_deg        = ligne.getInt("Latitude degrés");
    int    o_lat_min        = ligne.getInt("Latitude minutes");
    int    o_lat_dec        = ligne.getInt("Latitude décimale");
    int    o_lat_rad        = ligne.getInt("Latitude radian");
    int    o_lon_deg        = ligne.getInt("Longitude degrés");
    int    o_lon_min        = ligne.getInt("Longitude minutes");
    int    o_lon_dec        = ligne.getInt("Longitude décimale");
    int    o_lon_rad        = ligne.getInt("Longitude radian");
    int    o_km_dep_vol     = ligne.getInt("KMs du départ (vol oiseau)");
    int    o_km_dep_corde   = ligne.getInt("KMs du départ (corde)");
    int    o_km_dep_seg     = ligne.getInt("KMs par étapes (segments)");
    int    o_km_etape_cumul = ligne.getInt("KMs par étapes (cumulé)");
    String o_objet          = ligne.getString("Objet");
    String o_lieu           = ligne.getString("Lieu");
    String o_contexte       = ligne.getString("Contexte");
    String o_categorie      = ligne.getString("Catégorie");
    String o_post           = ligne.getString("Post");
    String o_jour           = ligne.getString("Jour");
    String o_titre          = ligne.getString("Titre");
    int    o_poids          = ligne.getInt("Poids (g)");
    int    o_taille         = ligne.getInt("Taille (mm)");
    String o_couleur        = ligne.getString("Couleur");
    String o_matiere        = ligne.getString("Matière");
    String o_origine        = ligne.getString("Origine");
    String o_date_complete  = ligne.getString("Date");
    String o_coordonnees    = ligne.getString("Coordonnées");
   
  }*/
}

void draw() {
  background(0);
  noStroke();
  fill(128);
  
  // Affichage des valeurs reçues par OSC ********************************************
  text("/video/enveloppe/id :      " + video_enveloppe_id,      10,  30);
  text("/video/enveloppe/max :     " + video_enveloppe_max,     10,  50);
  text("/video/enveloppe/fadein :  " + video_enveloppe_fadein,  10,  70);
  text("/video/enveloppe/decay :   " + video_enveloppe_decay,   10,  90);
  text("/video/enveloppe/fadeout : " + video_enveloppe_fadeout, 10, 110);
  text("/video/control/color :     " + video_control_color,     10, 130);
  
  // Afficher l'image ****************************************************************
  int id = int(video_enveloppe_id);
  if (id < 1) id = 1;
  if (id > 1000) id = 1000;
  image(image_objet[id], 0, 200);
  
  // TEMP : Si, on a changé d'id, chercher des coordonnées au hasard pour le point du planisphere
  // et une couleur au hasard pour la sphere
  if (id != old_id) {
    plan_x = random(200, 680);
    plan_y = random(150, 440);
    r = random(60, 240);
    g = random(60, 240);
    b = random(60, 240);
    bulle = createShape(SPHERE, 100);
    bulle.setStroke(false);
    bulle.setTexture(image_objet[id]);
  }
  
  // Afficher le planisphere
  image(planisphere, 200, 150);
  
  // Tracer le point sur le planisphere
  tracerPointPlanisphere(plan_x, plan_y);
  
  // Afficher les données correspondant à l'objet choisi *****************************
  fill(255);
  int x_start = 220;
  int y_start = 50;
  TableRow ligne = objet.getRow(id-1);
  text(ligne.getString("Objet"), x_start, y_start);
  text(ligne.getString("Contexte"), x_start, y_start + 15);
  text(ligne.getString("Jour") + " - " + ligne.getString("Date"), x_start, y_start + 45);
  text(ligne.getString("Lieu"), x_start, y_start + 60);
  
  text("Poids : " + ligne.getInt("Poids (g)") + " g", x_start, y_start + 400);
  text("Taille : " + ligne.getInt("Taille (mm)") + " mm", x_start, y_start + 415);
  text("Couleur : " + ligne.getString("Couleur") + " mm", x_start, y_start + 430);
  text("Matière : " + ligne.getString("Matière"), x_start, y_start + 445);
  text("Origine : " + ligne.getString("Origine"), x_start, y_start + 460);
  
  x_start = 350;
  text("Latitude : " + ligne.getInt("Latitude degrés") + "°" + ligne.getInt("Latitude minutes") + "'", x_start, y_start + 400);
  text("Latitude : " + ligne.getInt("Longitude degrés") + "°" + ligne.getInt("Longitude minutes") + "'", x_start, y_start + 415);
  text("KMs jour : " + ligne.getInt("KMs jour") + " km", x_start, y_start + 430);
  text("KMs total : " + ligne.getInt("KMs cumulé") + " km", x_start, y_start + 445);
  text("Altitude : " + ligne.getInt("Altitude (m)") + " m", x_start, y_start + 460);
  
  // Dessiner la bulle d'image ********************************************************
  pushMatrix();
  translate(840, 300);
  spotLight(r, g, b, 0, 0, 400, 0, 0, -1, PI/4, 10);
  rotateY(map(mouseX,0,width,-PI,PI)+((float)frameCount / 100));
  rotateX(map(mouseY,0,width,-PI,PI));
  shape(bulle);
  popMatrix();
  
  // TEMP
  old_id = id; 
  
}

void chargerImages(String dir) {
  for (int i = 1; i <= 1000; i++) {
    String chemin = dir + "/J" + i + ".gif";
    File f = dataFile(chemin);

    if (f.isFile()) {
      image_objet[i] = loadImage(chemin);
    } else {
      println("Le fichier " + chemin + " n'existe pas");
      image_objet[i] = createImage(200, 200, RGB);
    }
  }
}

void tracerPointPlanisphere(float x, float y) {
  ellipseMode(CENTER);
  fill(255, 15);
  for (int i = 30; i > 5; i -= 3) {
    ellipse(x, y, i, i);
  }
  fill(255, 255);
}

// Attribution des valeurs aux variables selon les messages OSC reçus 
void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/video/enveloppe/id") == true) {
    video_enveloppe_id = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/max") == true) {
    video_enveloppe_max = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/fadein") == true) {
    video_enveloppe_fadein = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/decay") == true) {
    video_enveloppe_decay = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/enveloppe/fadeout") == true) {
    video_enveloppe_fadeout = theOscMessage.get(0).floatValue();
    return;
  } 
  if (theOscMessage.checkAddrPattern("/video/control/color") == true) {
    video_control_color = theOscMessage.get(0).floatValue();
    return;
  }
}
