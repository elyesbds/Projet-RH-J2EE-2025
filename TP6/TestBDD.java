import org.hibernate.Session;

import java.util.HashSet;
import java.util.Set;

public class TestBDD {

    private Session session;

    public static void main(String[] args) {

        new TestBDD().run();
    }

    private void run() {

        session= HibernateUtil.
                getSessionFactory().openSession();

        session.beginTransaction();


        Individu individu1 =save( new Individu(1,"Kidman","Nicole"));
        Individu individu2 =save( new Individu(2,"Bettany","Paul"));
        Individu individu3 =save( new Individu(3,"Watson","Emily"));
        Individu individu4 =save( new Individu(4,"Skarsgard","Stellan"));
        Individu individu5 =save( new Individu(5,"Travolta","John"));
        Individu individu6 =save( new Individu(6,"L. Jackson","Samuel"));
        Individu individu7 =save( new Individu(7,"Willis","Bruce"));
        Individu individu8 =save( new Individu(8,"Irons","Jeremy"));
        Individu individu9 =save( new Individu(9,"Spader","James"));
        Individu individu10 =save( new Individu(10,"Hunter","Holly"));
        Individu individu11 =save( new Individu(11,"Arquette","Rosanna"));
        Individu individu12 =save( new Individu(12,"Wayne","John"));
        Individu individu13 =save( new Individu(13,"von Trier","Lars") );
        Individu individu14 =save( new Individu(14,"Tarantino","Quentin"));
        Individu individu15 =save( new Individu(15,"Cronenberg","David"));
        Individu individu16 =save( new Individu(16,"Mazursky","Paul"));
        Individu individu17 =save( new Individu(17,"Jones","Grace"));
        Individu individu18 =save( new Individu(18,"Glen","John"));


        Film film5 =save( new Film(5,individu13,"Dogville","Drame",2002));
        Film film4 =save( new Film(4,individu13,"Breaking the waves","Drame",1996));
        Film film3 =save( new Film(3,individu14,"Pulp Fiction","Policier",1994));
        Film film2 =save( new Film(2,individu15,"Faux-Semblants","Epouvante",1988));
        Film film1 =save( new Film(1,individu15,"Crash","Drame",1996));
        Film film6 =save( new Film(6,individu12,"Alamo","Western",1960));
        Film film7 =save( new Film(7,individu18,"Dangereusement vôtre","Espionnage",1985));


        Cinema cinema2 = save(new Cinema(2,"Le Fontenelle","78160 Marly-le-Roi"));
        Cinema cinema1 = save(new Cinema(1,"Le Renoir","13100 Aix-en-Provence"));
        Cinema cinema3 = save(new Cinema(3,"Gaumont Wilson","31000 Toulouse"));
        Cinema cinema4 = save(new Cinema(4,"Espace Ciné","93800 Epinay-sur-Seine"));



        Jouer jouer1 = save(new Jouer(individu1,film5,"Grace"));
        Jouer jouer2 = save(new Jouer(individu2,film5,"Tom Edison"));
        Jouer jouer3 = save(new Jouer(individu3,film4,"Bess"));
        Jouer jouer4a = save(new Jouer(individu4,film4,"Jan"));
        Jouer jouer5 = save(new Jouer(individu5,film3,"Vincent Vega"));
        Jouer jouer6 = save(new Jouer(individu6,film3,"Jules Winnfield"));
        Jouer jouer7 = save(new Jouer(individu7,film3,"Butch Coolidge"));
        Jouer jouer8 = save(new Jouer(individu8,film2,"Beverly & Elliot Mantle"));
        Jouer jouer9 = save(new Jouer(individu9,film1,"James Ballard"));
        Jouer jouer10 = save(new Jouer(individu10,film1,"Helen Remington"));
        Jouer jouer11 = save(new Jouer(individu11,film1,"Gabrielle"));
        Jouer jouer4b = save(new Jouer(individu4,film5,"Chuck"));
        Jouer jouer16 = save(new Jouer(individu16,film7,"May Day"));


        Projection projection1 = save(new Projection(cinema2,film5,"01/05/2002"));
        Projection projection2 = save(new Projection(cinema2,film5,"02/05/2002"));
        Projection projection3 = save(new Projection(cinema2,film5,"03/05/2002"));
        Projection projection4 = save(new Projection(cinema2,film4,"02/12/1996"));
        Projection projection5 = save(new Projection(cinema1,film1,"07/05/1996"));
        Projection projection6 = save(new Projection(cinema2,film7,"09/05/1985"));
        Projection projection7 = save(new Projection(cinema1,film4,"02/08/1996"));
        Projection projection8 = save(new Projection(cinema4,film3,"08/04/1994"));
        Projection projection9 = save(new Projection(cinema3,film6,"02/12/1990"));
        Projection projection10 = save(new Projection(cinema2,film2,"25/09/1990"));
        Projection projection11 = save(new Projection(cinema3,film3,"05/11/1994"));
        Projection projection12 = save(new Projection(cinema4,film3,"06/11/1994"));
        Projection projection13 = save(new Projection(cinema1,film6,"05/07/1980"));
        Projection projection14 = save(new Projection(cinema2,film4,"02/09/1996"));
        Projection projection15 = save(new Projection(cinema4,film6,"01/08/2002"));
        Projection projection16 = save(new Projection(cinema3,film6,"09/11/1960"));
        Projection projection17 = save(new Projection(cinema1,film2,"12/03/1988"));



        session.getTransaction().commit();
        session.close();

    }

    private<T>  T save(T o) {
        session.save(o);
        return o;

    }

}

