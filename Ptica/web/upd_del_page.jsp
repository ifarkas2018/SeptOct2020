<%-- 
    Dokument   : upd_del_page
    Formiran   : 12-March-2019, 16:15:01
    Autor      : Ingrid Farkaš
    Projekat   : Ptica
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page import="connection.ConnectionManager"%>
<%@page import="miscellaneous.PticaMetodi"%>

<!-- upd_del_page.jsp - prikazuje se kada korisnik klikne na dugme Pošalji na upd_del_title.jsp -->
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
       <%
            HttpSession hSesija = PticaMetodi.vratiSesiju(request);    
            String izvor1 = (String)hSesija.getAttribute("ime_izvora"); // naziv veb strane na kojoj sam sada
        %>
        
        <title>Ptica - <%= izvor1 %></title>
        <!-- povezivanje sa eksternom listom stilova -->
        <link href="css/templatecss.css" rel="stylesheet" type="text/css">
    </head>

    <body>
        <%
            String popunjeno = "false"; // da li varijable sesije sadrže vrednosti polja ( u obrazcu update_prev.jsp )
            String rs_upit = ""; 
            String preth_naslov = "";
            String preth_aut = "";
            String preth_isbn = "";
            ResultSet rs; // objekat u kome se čuva rezultat upita
            
            try {
                
                Connection con = ConnectionManager.getConnection(); // povezivanje sa bazom
                Statement stmt = con.createStatement();

                // ako varijabla sesije popunjeno postoji tada je pročitaj
                if (PticaMetodi.varSesijePostoji(hSesija, "popunjeno")) {
                    popunjeno = String.valueOf(hSesija.getAttribute("popunjeno"));
                } 
                
                // ako korisnik nije prethodno učitao ovu veb stranicu i uneo email ( Newsletter ) tada je prethodno učitao 
                // upd_del_title.jsp sa naslovom, autorom, isbn-om ( inače je uneo email adresu a ne naslov, autor, isbn ) 
                // pročitaj ih
                if (popunjeno.equalsIgnoreCase("false")) { 
                    preth_naslov = request.getParameter("preth_naslov"); // naslov ( upd_del_title.jsp )
                    preth_aut = request.getParameter("preth_autor"); // autor ( upd_del_title.jsp )
                    preth_isbn = request.getParameter("preth_isbn"); // isbn ( upd_del_title.jsp )
                    
                    // izbrisiPrazno: uklanja prazan prostor sa početka i kraja stringa i zamenjuje 2 ili više prazna mesta ( unutar
                    // stringa ) sa jednim praznim mestom
                    preth_naslov = PticaMetodi.izbrisiPrazno(preth_naslov);
                    preth_aut = PticaMetodi.izbrisiPrazno(preth_aut);
                    preth_isbn = PticaMetodi.izbrisiPrazno(preth_isbn);
                    
                    // dKosuC : zamenjuje svaku pojavu \ sa \\\\ i zamenjuje svaku pojavu ' sa \\'
                    preth_naslov = PticaMetodi.dKosuC(preth_naslov);
                    preth_aut = PticaMetodi.dKosuC(preth_aut);
                    
                    // dodaj sesiji preth_naslov, preth_aut, preth_isbn
                    hSesija.setAttribute("preth_naslov", preth_naslov); // PRETHODNI naslov knjige
                    hSesija.setAttribute("preth_autor", preth_aut); // prethodni autor
                    hSesija.setAttribute("preth_isbn", preth_isbn); // prethodni isbn
                } else {
                    // ako je popunjeno true znači da je korisnik prethodno učitao ovu stranicu ( varijable sesije su bile postavljene ),
                    // posle toga on je uneo email adresu ( Newsletter ). Sada treba da pročitam varijable sesije.
                    preth_naslov = String.valueOf(hSesija.getAttribute("preth_naslov")); // PRETHODNI naslov knjige
                    preth_aut = String.valueOf(hSesija.getAttribute("preth_aut")); // pročitaj autora 
                    preth_isbn = String.valueOf(hSesija.getAttribute("preth_isbn")); // pročitaj isbn
                }
                
                String brknj = ""; // id knjige
                
                // traženje br_knjige za knjigu sa naslovom preth_naslov, autorom preth_aut, isbn-om preth_isbn
                // formiranje upita :
                // SELECT k.br_knjige,
                // FROM knjiga k, autor a
                // WHERE k.br_autora = a.br_autora AND k.isbn = 'preth_isbn' AND k.naslov = 'preth_naslov' AND a.ime_autora = 'preth_aut';
                rs_upit = "SELECT k.br_knjige FROM knjiga k , autor a WHERE k.br_autora = a.br_autora";
                
                // dodavanje autora upitu 
                if ((!((preth_aut.equalsIgnoreCase("")))) && (!((preth_aut.equalsIgnoreCase("null")))) && (preth_aut != null)) {
                    rs_upit += " AND a.ime_autora = "; 
                    rs_upit += "'" + preth_aut + "'";
                }
                
                // dodavanje naslova upitu 
                if ((!((preth_naslov.equalsIgnoreCase("")))) && (!((preth_naslov.equalsIgnoreCase("null")))) && (preth_naslov != null)) {
                    rs_upit +=" AND k.naslov = ";
                    rs_upit += "'" + preth_naslov + "'";
                }
                
                // dodavanje isbn-a upitu
                if ((!((preth_isbn.equalsIgnoreCase("")))) && (!((preth_isbn.equalsIgnoreCase("null")))) && (preth_isbn != null)) {
                    rs_upit += " AND k.isbn ='" + preth_isbn + "'";
                }
                
                rs_upit += ";";
                rs = stmt.executeQuery(rs_upit);
                
                // ako rezultat upita ima bar jedan slog
                if (rs.next()) {
                    // nalazim br_knjige za uneseni naslov, autor, isbn
                    brknj = rs.getString("br_knjige");
                    hSesija.setAttribute("brknj", brknj); // čuvam book id u varijabli sesije brknj
                } else {
                    String sNaslov = "";
                    brknj = "";
                    // prikaži veb stranicu sa porukom da se knjiga ne može naći u bazi podataka               
                    if (izvor1.equalsIgnoreCase("Brisanje knjige")) {
                        hSesija.setAttribute("ime_izvora", "Brisanje knjige"); // naziv veb strane na kojoj sam sada
                    } else if (izvor1.equalsIgnoreCase("Ažuriranje knjige")) {
                        hSesija.setAttribute("ime_izvora", "Ažuriranje knjige"); // naziv veb strane na kojoj sam sada
                    }
                    String sPoruka = "GR_NE_POST_KNJ"; // koristi se za prosleđivanje poruke
                    sNaslov = "Greška"; // koristi se za prosleđivanje naslova
                    hSesija.setAttribute("poruka", sPoruka);
                    hSesija.setAttribute("naslov", sNaslov);
                    response.sendRedirect("error_succ.jsp"); // preusmeravanje na error_succ.jsp    
                }
            } catch (Exception e){
                String sNaslov = "Greška"; // koristi se za prosleđivanje naslova
                String sPoruka = "GR_BAZA"; // koristi se za prosleđivanje poruke
                if (izvor1.equalsIgnoreCase("Ažuriranje knjige"))
                    hSesija.setAttribute("ime_izvora", "Ažuriranje knjige"); // naziv veb strane na kojoj sam sada
                else
                    hSesija.setAttribute("ime_izvora", "Brisanje knjige"); // naziv veb strane na kojoj sam sada
                hSesija.setAttribute("poruka", sPoruka); 
                hSesija.setAttribute("naslov", sNaslov); 
                response.sendRedirect("error_succ.jsp"); // preusmeravanje na error_succ.jsp  
            }
        %>
        
        <!-- header.jsp sadrži - logo i ime kompanije i navigaciju -->
        <%@ include file="header.jsp"%>
        <%@ include file="upd_del_form.jsp"%> 
        <!-- footer.jsp sadrži footer -->  
        <%@ include file="footer.jsp"%>
    </body>
</html>
