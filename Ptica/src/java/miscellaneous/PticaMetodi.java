/*
 * autor    : Ingrid Farkaš
 * projekat : Ptica
 * PticaMetodi.java : metodi koji se koriste više puta
 */
package miscellaneous;

import java.util.Enumeration;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public class PticaMetodi {
    
    public static HttpSession vratiSesiju(HttpServletRequest request) {
        HttpSession hSesija = request.getSession(); // sesija kojoj ću dodati varijable
        return hSesija;
    }
    
    // varSesijePostoji: vraća da li varijabla sesije ime postoji u hSesija
    public static boolean varSesijePostoji(HttpSession hSesija, String ime) { 
        boolean nadjen_atr = false; // da li postoji varijabla sesije ime
        String imeAtr = ""; // ime varijable u sesiji
        Enumeration enumAtr; // sadrži imena varijabli koje sam dodala sesiji  
        enumAtr = hSesija.getAttributeNames(); // čitam imena varijabli sesije 
        while ((enumAtr.hasMoreElements()) && (!nadjen_atr)) { // ako postoji sledeći element
            imeAtr = String.valueOf(enumAtr.nextElement()); // čitam sledeći element
            if (imeAtr.equals(ime)) {
                nadjen_atr = true; // pronađena je varijabla sesije sa imenom ime 
            }
        }
        return nadjen_atr;
    }
    
    // citajVarSesije : čita i vraća vrednost varijable sesije varSesije
    // varSesije : ime varijable sesije
    public static String citajVarSesije(HttpSession hSesija, String varSesije) {
        String vrednost = "";
        
        // ako je korisnik uneo email ( Newsletter ) tada čitam vrednost varijable varSesije
        if (PticaMetodi.varSesijePostoji(hSesija, varSesije)) { 
            vrednost = String.valueOf(hSesija.getAttribute(varSesije));
            if (!vrednost.equalsIgnoreCase("")) { 
                hSesija.setAttribute(varSesije, ""); // sledeći put stranica je prikazana varSesije je ""  
            }
        } 
        return vrednost;
    }
    
    // postaviNaPrazno: postavi vrednost varijable sesije na "" za varijable input0, input1, ...
    public static void postaviNaPrazno(HttpSession hSesija) {
        String imeAtr = ""; // ime varijable sesije
        Enumeration enumAtr; // sadrži imena varijabli u sesiji
        enumAtr = hSesija.getAttributeNames(); // imena varijabli sesije  
        while ((enumAtr.hasMoreElements())) { // ako postoji sledeći element
            imeAtr = String.valueOf(enumAtr.nextElement()); // čitam sledeći element
            if (imeAtr.startsWith("input")) {
                hSesija.removeAttribute(imeAtr);
            }
        }
    }
    
    // postNaPrazno: postavi vrednost varijable sesije na "" 
    public static void postNaPrazno(HttpSession hSesija) {
        String imeAtr = ""; // ime varijable sesije
        Enumeration enumAtr;   
        enumAtr = hSesija.getAttributeNames(); // imena varijabli sesije 
        while ((enumAtr.hasMoreElements())) { // ako postoji sledeći element
            imeAtr = String.valueOf(enumAtr.nextElement()); // čitam sledeći element
            hSesija.removeAttribute(imeAtr); 
        }
    }
    
    // dodKosuC : dodaje dve \ ( ako jeApostrof = true ) ispred ' 
    // ili tri \ ( ako jeApostrof = false ) ispred \ pre SVAKE pojave tog karaktera 
    // koristi se prilikom dodavanja opisa ( ili nekog drugog stringa ) bazi
    public static String dodKosuC(String opis, boolean jeApostrof){
        
        String novOpis = ""; // string u kome dodajem \ ispred '
        String strDoChar; // podstring stringa opisa do \ ili '
        String strCharacter; // string koji se dodaje umesto ' ( ili \ )
        String strPosleChar; // podstring opisa iza ' ( ili \ )
        int preth_poz = -1; // pozicija prethodnog ' ili \
        int poz = 1; // pozicija ' ili \
        int stringLen = opis.length();
        
        if (jeApostrof) { 
            strCharacter = "\\'";
        } else {
            strCharacter = "\\\\";
        }
        
        if (!jeApostrof) {
            poz = opis.indexOf("\\", 0); // pronalazi poziciju \ počevši od pozicije preth_poz + 3
        } else { 
            poz = opis.indexOf("'", 0); // pronalazi poziciju ' počevši od pozicije preth_poz + 3
        }
        
        if (poz < 0)
            novOpis = opis;
         
        // dok postoji sledeći \ zameni ga sa \\\\ ( ili dok postoji sledeći ' zameni ga sa \\' )
        while (poz >= 0) {
            novOpis = "";
            preth_poz = poz - 1;
            
            if (poz >= 0) {
                strDoChar = opis.substring(0, poz);
                strPosleChar = opis.substring(poz + 1, stringLen);
                novOpis = novOpis.concat(strDoChar);
                novOpis = novOpis.concat(strCharacter);
                novOpis = novOpis.concat(strPosleChar);
                opis = novOpis;
                
                stringLen++; // dodala sam stringu \
                
                if (!jeApostrof) {
                    poz = opis.indexOf("\\", preth_poz + 3); // pronalazi poziciju \ počevši od pozicije preth_poz + 3
                } else { 
                    poz = opis.indexOf("'", preth_poz + 3); // pronalazi poziciju ' počevši od pozicije preth_poz + 3
                }
            }
        }
        return novOpis;
    }
    
    // dKosuC : poziva metod koji zamenjuje svaku pojavu \ sa \\\\ i zamenjuje svaku pojavu ' sa \\'
    public static String dKosuC(String opis) {
        boolean jeApostrof = false; // da li je karakter pre koga treba da dodam \\ je ' ( ili \ )
                
        // zamenjuje svaku pojavu \ sa \\\\
        opis = dodKosuC(opis, jeApostrof);
        jeApostrof = true;
        // zamenjuje svaku pojavu ' sa \\'
        opis = dodKosuC(opis, jeApostrof);
       
        return opis;
    }
    
    // izbrisiPrazno: uklanja prazan prostor sa početka i kraja stringa i zamenjuje 2 ili više prazna mesta ( unutar stringa )
    // sa jednim praznim mestom
    public static String izbrisiPrazno(String str) {
        String noviString = str.trim(); // uklanja prazan prostor sa početka i kraja stringa
        noviString = noviString.replaceAll("\\s+", " "); // zamenjuje 2 ili više prazna mesta sa jednim praznim mestom
        return noviString;
    }
    
    // dodajTacku: dodaje tačku u cenu iza hiljadu dinara 
    public static String dodajTacku(String cena) {
        if (cena.length() > 6) {
            String substrLevi = ""; // deo stringa s leva do .
            String substrDesni = ""; // deo stringa s desne strane do .
            if (cena.length() == 7) {
                substrLevi = cena.substring(0,1);
                substrDesni = cena.substring(1);
            } else if (cena.length() == 8) {
                substrLevi = cena.substring(0,2);
                substrDesni = cena.substring(2);
            }
            cena = "";
            cena = cena.concat(substrLevi); 
            cena = cena.concat(".");
            cena = cena.concat(substrDesni);
        }
        return cena;
    }
}
