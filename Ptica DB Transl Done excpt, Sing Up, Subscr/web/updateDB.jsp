<%-- 
    Dokument   : updateDB poziva se iz update_form.jsp
    Formiran   : 14-Mar-2019, 04:09:42
    Autor      : Ingrid Farkaš
    Projekat   : Ptica
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="connection.ConnectionManager"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="miscellaneous.PticaMetodi"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="css/templatecss.css" type="text/css" rel="stylesheet"/>
        <title>Ptica - Ažuriranje knjige</title>
        
        <%@ include file="header.jsp"%>
    </head>
    
    <body>
        <%!
            // za izdavača sa imenom ime_izd vraća broj izdavača 
            String odrediBRIzd(String ime_izd, Statement stmt) { 
                try {
                    // formiranje upita SELECT br_izdavača FROM izdavač WHERE ime_izdavača='...';
                    String brizd = ""; // broj izdavača 
                    String rs_upit = "SELECT br_izdavača"; 
                    rs_upit += " FROM izdavač WHERE ime_izdavača='" + ime_izd + "'";
                    rs_upit += ";";   
                    
                    // izvršavanje upita
                    ResultSet rs = stmt.executeQuery(rs_upit);
                    
                    // ako rezultat izvršavanja upita nije prazan, pročitaj broj izdavača
                    if (rs.next()) 
                        brizd = rs.getString("br_izdavača");
                    return brizd;
                } catch (SQLException ex) {
                    return ""; // ako je došlo do izuzetka vraća broj izdavača = ""
                }
            }
            
            // ako autor sa imenom ime_aut postoji vraća id autora
            String odrediBRAut(String ime_aut, Statement stmt) { 
                try {
                    // formiranje upita SELECT br_autora FROM autor WHERE ime_autora='...';
                    String braut = ""; // broj autora
                    String rs_upit = "SELECT br_autora "; 
                    rs_upit += "FROM autor WHERE ime_autora='" + ime_aut + "'";
                    rs_upit += ";";   
                    // izvršavanje upita
                    ResultSet rs = stmt.executeQuery(rs_upit);
                    // ako rezultat izvršavanja upita nije prazan, pročitaj broj autora
                    if (rs.next()) 
                        braut = rs.getString("br_autora");
                    return braut;
                } catch ( SQLException ex) {
                    return ""; // ako je došlo do izuzetka vraća broj autora = ""
                }
            }
        %>   
        
        <%
            // sesija kojoj ću dodati atribute
            HttpSession hSesija = request.getSession();
            try { 
                String f_naslov = request.getParameter("naslov"); // naslov
                String f_autor = request.getParameter("autor"); // autor
                String f_isbn = request.getParameter("isbn"); // isbn 
                String f_cena = request.getParameter("cena"); // cena
                String f_strane = request.getParameter("strane"); // broj stranica
                String f_zanr = request.getParameter("zanr"); // žanr
                String f_opis = request.getParameter("opis"); // opis knjige
                String f_izdavac = request.getParameter("izdavac"); // ime izdavača
                String f_gdizdav = request.getParameter("gd_izdav"); // godina izdavanja
                
                f_cena = f_cena.replace(".", "");
                f_cena = f_cena.replace(",", "."); // tip podatka za cenu je u bazi float

                // izbrisiPrazno: uklanja prazan prostor sa početka i kraja stringa i zamenjuje 2 ili više prazna mesta ( unutar stringa )
                // sa jednim praznim mestom
                f_naslov = PticaMetodi.izbrisiPrazno(f_naslov);
                f_autor = PticaMetodi.izbrisiPrazno(f_autor);
                f_isbn = PticaMetodi.izbrisiPrazno(f_isbn);
                f_cena = PticaMetodi.izbrisiPrazno(f_cena);
                f_strane = PticaMetodi.izbrisiPrazno(f_strane);
                f_izdavac = PticaMetodi.izbrisiPrazno(f_izdavac);
                f_opis = PticaMetodi.izbrisiPrazno(f_opis);

                // dKosuC zamenjuje svaku pojavu \ sa \\\\ i zamenjuje svaku pojavu ' sa \\'
                f_naslov = PticaMetodi.dKosuC(f_naslov);
                f_autor = PticaMetodi.dKosuC(f_autor);
                f_izdavac = PticaMetodi.dKosuC(f_izdavac);
                f_opis = PticaMetodi.dKosuC(f_opis);

                Connection con = ConnectionManager.getConnection(); // povezivanje sa bazom
                Statement stmt = con.createStatement();

                String rs_upit=""; 
                ResultSet rs; // objekat gde se čuva rezultat upita
                String brau = ""; // broj autora
                String brizd = ""; // broj izdavača  
                String brknj = ""; // broj knjige

                // ODREĐIVANJE ID IZDAVAČA 
                if (!((f_izdavac.equalsIgnoreCase("")))) {
                    // odrediBRIzd : formiranje i izvršavanje upita SELECT br_izdavača, city FROM publisher WHERE ime_izd='...' AND city='...';
                    brizd = odrediBRIzd(f_izdavac, stmt); // određuje ID izdavača za zadati izdavač ( u tom gradu )
                     

                    if (brizd.equals("")) { // ako izdavač sa tim imenom ne postoji, tada se novi izdavač dodaje tabeli publisher 
                        
                        // formiranje stringa "INSERT INTO publisher(ime_izd, city) VALUES ('...', '...');
                        // i izvršavanje upita
                        rs_upit = "INSERT INTO izdavač(ime_izdavača";
                        rs_upit += ") VALUES ('" + f_izdavac + "'";
                        rs_upit += ");";

                        PreparedStatement preparedStmt = con.prepareStatement(rs_upit);
                        preparedStmt.execute();

                        // određivanje br_izdavača za dodati izdavač
                        brizd = odrediBRIzd(f_izdavac, stmt);
                    }
                }

                // ODREĐIVANJE ID AUTORA
                if (!((f_autor.equalsIgnoreCase("")))) {
                    // odrediBRAut : formiranje i izvršavanje upita SELECT br_autora FROM autor WHERE ime_autora='...';
                    brau = odrediBRAut(f_autor, stmt); // određivanje ID autora za tog authora
                    // ako autor sa tim imenom ne postoji, dodaj ga tabeli autor
                    if (brau.equals("")) { 
                        // formiranje stringa "INSERT INTO autor(ime_autora) VALUES ('...');
                        // i izvršavanje upita
                        rs_upit = "INSERT INTO autor(ime_autora) ";
                        rs_upit += "VALUES ('" + f_autor + "');";

                        PreparedStatement preparedStmt = con.prepareStatement(rs_upit);
                        preparedStmt.execute();
                        // određivanje br_izdavača za dodatog izdavača
                        brau = odrediBRAut(f_autor, stmt);
                    }
                }

                // čitaj ID knjige iz sesije
                brknj = String.valueOf(hSesija.getAttribute("brknj"));

                // TABELA knjiga : upit update
                boolean je_dodato = false; // da li je ime neke kolone dodato upitu update
                String upit = "update knjiga set ";

                // ako je ime autora novo, dodaj upitu br_autora = brau
                // brau sam odredila pre pozivom metoda odrediBRAut(f_autor, stmt)
                if (!((f_autor.equalsIgnoreCase("")))) {
                    upit += "br_autora='" + brau + "'";
                    je_dodato = true; // ime kolone je dodato upitu update 
                }

                // ako je ime idavača novo dodaj upitu br_izdavača = brizd
                // brizd sam odredila pre pozivom metoda odrediBRIzd(f_izdavac, stmt)
                if (!(f_izdavac.equalsIgnoreCase("")))  {
                    // ako je prethodno dodato br_autora = '...' tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "br_izdavača='" + brizd + "'";
                    je_dodato = true; // ime kolone je bilo dodato upitu update
                }

                // ako postoji novi naslov tada dodaj upitu title = f_naslov
                if (!((f_naslov.equalsIgnoreCase("")))) {
                    // ako je prethodno dodato br_izdavača = '...' ( ili neka druga kolona ) tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "naslov='" + f_naslov + "'";
                    je_dodato = true;
                }

                // ako je isbn ima novu vrednost tada dodaj upitu isbn = f_isbn
                if (!((f_isbn.equalsIgnoreCase("")))) {
                    // ako je prethodno dodato title='...' tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "isbn='" + f_isbn + "'";
                    je_dodato = true;
                }

                // ako cena ima novu vrednost tada dodaj upitu price = f_cena
                f_cena = f_cena.replaceAll(" ", "");
                if (!((f_cena.equalsIgnoreCase("")))) {
                    // ako je prethodno dodato isbn = '...' ( ili neka druga kolona ) tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "cena='" + f_cena + "'";
                    je_dodato = true;
                }

                // ako broj strana ima novu vrednost tada dodaj upitu pages = form_pages
                if (!((f_strane.equalsIgnoreCase("")))) {
                    // ako je prethodno dodato price = '...' ( ili neka druga kolona ) tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "br_strana='" + f_strane + "'";
                    je_dodato = true;
                }

                // ako žanr ima novu vrednost tada dodaj upitu category = f_zanr
                if (!((f_zanr.equalsIgnoreCase("")))) {
                    // ako je prethodno dodato pages = '...' ( ili neka druga kolona ) tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "žanr='" + f_zanr + "'";
                    je_dodato = true;
                }

                // ako opis ima novu vrednost tada dodaj upitu descr = f_opis
                if (!((f_opis.equalsIgnoreCase("")))) {
                    // ako je prethodno dodato category = '...' ( ili neka druga kolona ) tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "opis='" + f_opis + "'";
                    je_dodato = true;
                }

                // ako godina izdavanja ima novu vrednost tada dodaj upitu publ_year = f_gdizdav
                if (!((f_gdizdav.equalsIgnoreCase("")))) {
                    // ako je prethodno dodato category = '...' ( ili neka druga kolona ) tada dodajem zarez
                    if (je_dodato){
                        upit += ",";
                    }
                    upit += "god_izdavanja='" + f_gdizdav + "'";
                    je_dodato = true;
                }

                upit += " where br_knjige='" + brknj + "';";           

                PreparedStatement preparedStmt = con.prepareStatement(upit);
                preparedStmt.execute();

                // prikaži veb stranicu sa porukom da je knjiga uspešno ažurirana u bazi
                hSesija.setAttribute("ime_izvora", "Ažuriranje knjige"); // naziv veb strane na kojoj sam sada
                String sNaslov = "Ažuriranje knjige"; // koristi se za prosleđivanje naslova 
                String sPoruka = "USPEH_AZUR"; // koristi se za prosleđivanje poruke
                hSesija.setAttribute("poruka", sPoruka);
                hSesija.setAttribute("naslov", sNaslov);
                response.sendRedirect("error_succ.jsp"); // preusmeravanje na error_succ.jsp    
        %>
        
        <br>
        <br>
        
        <%
            out.print(" ");
        %>
             
        <%
            } catch(Exception e) { // ako je došlo  do izuzetka postavljam varijable sesije
                String sNaslov = "Greška"; // koristi se za prosleđivanje naslova
                String sPoruka = "GR_AZUR"; // koristi se za prosleđivanje poruke
                hSesija.setAttribute("ime_izvora", "Ažuriranje knjige"); // naziv veb strane na kojoj sam sada
                hSesija.setAttribute("poruka", sPoruka); 
                hSesija.setAttribute("naslov", sNaslov); 
                response.sendRedirect("error_succ.jsp"); // preusmeravanje na error_succ.jsp   
            }
        %>
       
    <%@ include file="footer.jsp"%>
    </body>
</html>