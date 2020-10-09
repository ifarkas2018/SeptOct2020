/* Projekat : Ptica
 * Autor : Ingrid Farkaš
 * validacija.js: funkcije korišćene za validaciju
 */

CELOIME_VR = 'true'; // da li input field za celo ime sadrži samo slova( i apostrof )
IME_VR = 'true'; // da li input field za ime sadrži samo slova( i apostrof )
PREZIME_VR = 'true'; // da li input field za prezime sadrži samo slova( i apostrof )
ISBN_VR = 'true'; // da li ISBN input field sadrži samo cifre
CENA_VR = 'true'; // da li input field za cenu sadrži samo cifre( i tačku i zarez )
STR_VR = 'true'; // da li input field za broj stranica sadrži samo cifre
GODIZDAV_VR = 'true'; // da li input field za godinu izdavanja sadrži samo cifre

// postaviVred: zavisno od vrsta_broja, postavlja jednu od variabli na vrednost vrednost
function postaviVred(vrsta_broja, vrednost) {
    if (vrsta_broja == 'je_isbn') {
        ISBN_VR = vrednost;
    } else if (vrsta_broja == 'je_brstr') {
        STR_VR = vrednost;
    } else if (vrsta_broja == 'je_cena') {
        CENA_VR = vrednost;
    } else if (vrsta_broja == 'je_godizd') {
        GODIZDAV_VR = vrednost;
    }
}

// broj: prikazuje poruku(u polje_poruka) ako je korisnik uneo vrednost koja nije broj(u input field za nazivom input_polje)
// ako je karakteri true, broj može da sadrži % ili _
// ako je dec_tacka true, broj može da sadrži .
// vrsta_broja - da li je unos u input field-u isbn, cena, broj stranica ili godina
// formid: id forme
function broj(formid, input_polje, vrsta_broja, polje_poruka, karakteri, dec_tacka) {
    var broj_polje;
    var regex;
   
    broj_polje = document.getElementById(input_polje).value;  
    if (karakteri && dec_tacka) { // %, _ ili . može da se unese u input field( pored cifara )
        regex = /^[0-9\x25\x5F\x2E]+$/;
    } else if (dec_tacka) {
        regex = /^[0-9\x2E]+$/;
    } else if (karakteri) { // % or _ može da se unese u input field (pored cifara)
        regex = /^[0-9\x25\x5F]+$/;
    } else {
        regex = /^[0-9]+$/;
    }
    if (broj_polje != '') {
        // ako vrednost unesena za isbn nije broj (ako je karakteri true, broj može da sadrži % ili _)
        if (!regex.test(broj_polje)) {
            if (karakteri && dec_tacka) { // %, _, . can be entered in the input field ( beside digits )
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre (džoker znakove i decimalnu tačku)"; 
            } else if (dec_tacka) { 
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre (i decimalnu tačku)"; // prikaži poruku 
            } else if (karakteri) {
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre (i džoker znakove)"; 
            } else {
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cifre."; 
            }
            postaviVred(vrsta_broja, 'false'); 
        } else {
            postaviVred(vrsta_broja, 'true');
            document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku 
        }
    } else {
        postaviVred(vrsta_broja, 'true');
        document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku 
    }
    
}

// dalijeCena: prikazuje poruku (u polje_poruka) ako je korisnik uneo vrednost koja nije cena (u input field za nazivom input_polje)
// vrsta_broja - da li je unos u input field-u isbn, cena, broj stranica ili godina
// formid: id forme
function daLiJeCena(formid, input_polje, vrsta_broja, polje_poruka) {
    var broj_polje;
    var regex;
    
    broj_polje = document.getElementById(input_polje).value;
    regex = /^[0-9\x2C\x2E]+$/; // može da sadrži cifre, zarez i decimalnu tačku
    if (broj_polje.length > 9) {
        document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cenu manju ili jednaku 99.999,99"; 
        postaviVred(vrsta_broja, 'false');
    } else {
        if (broj_polje != '') {
            // ako vrednost unesena za isbn nije broj
            if (!regex.test(broj_polje)) { 
                document.getElementById(polje_poruka).innerHTML = "Ovo polje može da sadrži cenu ( cifre, tačku i zarez )"; 
                postaviVred(vrsta_broja, 'false');
            } else {
                postaviVred(vrsta_broja, 'true');
                document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku  
            }
        } else {
            postaviVred( vrsta_broja, 'true' );
            document.getElementById(polje_poruka).innerHTML = ""; // prikaži poruku  
        }
    }
}

// postaviVrImena - zavisno da li je korisnik uneo celo ime, ime ili prezime postavi vrednost odgovarajuće varijable
// vrsta_imena: 'celoime' (korisnik uneo celo ime), 'ime', 'prezime' 
// vrednost: 'true' or 'false'
function postaviVrImena(vrsta_imena, vrednost) {
    switch (vrsta_imena) { // zavisno da li je korisnik uneo celo ime, ime ili prezime postavi vrednost odgovarajuće varijable
        case 'celoime':
            CELOIME_VR = vrednost;
            break;
        case 'ime':
            IME_VR = vrednost;
            break;
        case 'prezime':
            PREZIME_VR = vrednost;
            break;
        default:
    }
}

// slova: proverava da li su u input_polje unesena samo slova(ili apostrofi, zarezi, -, prazno mesto, %, _).
// ako je nešto drugo uneseno u poruka_span se prikazuje poruka
// kada korisnik ispravi grešku, ispod polja se više ne prikazuje poruka
// obavezno - da li je popunjavanje polja obavezno 
// vrsta_imena - 'celoime'(korisnik je uneo celo ime), 'ime', 'prezime'
// karakteri - da li se džoker znakovi mogu pojaviti u polju
function slova(input_polje, poruka_span, vrsta_imena, karakteri, obavezno) {
    var regex;
    
    if (karakteri) { // % ili _ može da se unese u polje (pored slova, apostrofa, zareza, -, praznog mesta)
        if (vrsta_imena == "celoime") { // može da sadrži više imena razdvojenih zarezom (Pretraga Knjiga, Nova Knj, Ažuriranje knj, Brisanje Knj)          
            regex = /^[a-zA-ZćĆčČšŠžŽđĐ\x27\x20\x2C\x2D\x25\x5F]+$/;
        } else { // ne može da sadrži više imena (zarez se ne pojavljuje) - Novi nalog
            if (vrsta_imena == "ime") { // pored zareza (\x2C) ne može da sadrži '(\x27)
                regex = /^[a-zA-ZćĆčČšŠžŽđĐ\x20\x2D\x25\x5F]+$/; // može da sadrži space - % _ (pored slova)
            } else { // ako je prezime
                regex = /^[a-zA-ZćĆčČšŠžŽđĐ\x27\x20\x2D\x25\x5F]+$/; // može da sadrži ' space - % _ (pored slova)
            }
        }
    } else {
        if (vrsta_imena == "celoime") { // može da sadrži više imena razdvojenih zarezom (Pretraga Knjiga, Nova Knj, Ažuriranje knj, Brisanje Knj)
            regex = /^[a-zA-ZćĆčČšŠžŽđĐ\x27\x20\x2C\x2D]+$/; // može da sadrži ' space , -  (pored slova)
        } else { // ne može da sadrži više imena (zarez se ne pojavljuje) - Novi nalog
            if (vrsta_imena == "ime") { // pored zareza (\x2C) ne može da sadrži '(\x27)  
                regex = /^[a-zA-ZćĆčČšŠžŽđĐ\x20\x2D]+$/; // može da sadrži space - (pored slova) 
            } else { // ako je prezime
                regex = /^[a-zA-ZćĆčČšŠžŽđĐ\x27\x20\x2D]+$/; // može da sadrži ' space - (pored slova)
            }
        }
    }
    
    if (!input_polje.value == '') {
        if (!regex.test(input_polje.value)) { // ako je korisnik uneo karaktere koja nisu slova i dozvoljeni znaci (u polje)
            if (karakteri) {
                if (vrsta_imena == "celoime") { // može da sadrži više imena razdvojenih zarezom (Pretraga Knjiga, Nova Knj, Ažuriranje knj, Brisanje Knj)
                    poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto, džoker znakove i ,'- ";
                } else { // ne može da sadrži više imena (zarez se ne pojavljuje) - Novi nalog   
                    if (vrsta_imena == "ime") {
                        poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto, džoker znakove i - ";
                    } else { // ako je prezime
                        poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto, džoker znakove i '- ";
                    }
                }   
            } else {
                if (vrsta_imena == "celoime") { // može da sadrži više imena razdvojenih zarezom (Pretraga Knjiga, Nova Knj, Ažuriranje knj, Brisanje Knj)
                    poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto, i znakove ,'- ";
                } else { // ne može da sadrži više imena (zarez se ne pojavljuje) - Novi nalog  
                    if (vrsta_imena == "ime") {
                        poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto i - ";
                    } else { // ako je prezime
                        poruka_span.innerHTML = "Ovo polje može da sadrži slova, prazno mesto i '- ";
                    }
                }
            }
            postaviVrImena(vrsta_imena, 'false');
        } else { // ako je korisnik uneo karaktere koja su slova i dozvoljene znakove (u polje)
            postaviVrImena(vrsta_imena, 'true');
            poruka_span.innerHTML = "";
        }
    } else { // ništa nije uneto u input field
        if (obavezno == 'true') { // ako je input field obavezno, a korisnik nije uneo ništa
            postaviVrImena(vrsta_imena, 'false');
            poruka_span.innerHTML = " ";
        } else { // ako je input field nije obavezno, a korisnik nije uneo ništa
            postaviVrImena(vrsta_imena, 'true');
            // alert(vrsta_imena + "false");
            // CELOIME_VR = 'true';
            poruka_span.innerHTML = "";
        }
    }
}

// proveriF: ako je validacija uspešna onda vraća TRUE inače vraća FALSE
function proveriF() {
    if ((CELOIME_VR === 'true') && (IME_VR === 'true') && (PREZIME_VR === 'true') && (ISBN_VR === 'true') && (CENA_VR === 'true') && (STR_VR === 'true') && (GODIZDAV_VR === 'true')) { 
        return true;
    } else {
        return false;
    }
}

