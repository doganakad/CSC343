import java.sql.*;
import java.util.Date;
import java.lang.*;
import java.text.*;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not received a high mark.  
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

public class Assignment2 {

	// A connection to the database
	Connection connection = null;
	String queryString = null;
	PreparedStatement pStatement = null;
	ResultSet rs = null;
	Statement stmt = null;

	Assignment2() throws SQLException {
		try {
			Class.forName("org.postgresql.Driver");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Connects and sets the search path.
	 *
	 * Establishes a connection to be used for this session, assigning it to the
	 * instance variable 'connection'. In addition, sets the search path to bnb.
	 *
	 * @param url
	 *            the url for the database
	 * @param username
	 *            the username to connect to the database
	 * @param password
	 *            the password to connect to the database
	 * @return true if connecting is successful, false otherwise
	 */
	public boolean connectDB(String URL, String username, String password) {
		// Implement this method!
		try {
			connection = DriverManager.getConnection(URL, username, password);
			return true;
		} catch (Exception e) {
			e.printStackTrace();
			System.err.println(e.getClass().getName() + ": " + e.getMessage());
			System.exit(0);
		}
		return false;
	}

	/**
	 * Closes the database connection.
	 *
	 * @return true if the closing was successful, false otherwise
	 */
	public boolean disconnectDB() {
		// Implement this method!
		try {
			connection.close();
			return true;
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println(e.getClass().getName() + ": " + e.getMessage());
			System.exit(0);
		}
		return false;
	}

	/**
	 * Returns the 10 most similar homeowners based on traveller reviews.
	 *
	 * Does so by using Cosine Similarity: the dot product between the columns
	 * representing different homeowners. If there is a tie for the 10th
	 * homeowner (only the 10th), more than 10 records may be returned.
	 *
	 * @param homeownerID
	 *            id of the homeowner
	 * @return a list of the 10 most similar homeowners
	 */
	public ArrayList homeownerRecommendation(int homeownerID) {
      // Implement this method!
	   try {
		   ArrayList<Integer> similars = new ArrayList<Integer>();
		   stmt = connection.createStatement();
		   pStatement = connection
		           .prepareStatement("SET search_path TO bnb,public;");
		   pStatement.execute();
		   String homeowner_query = "CREATE VIEW travelerbooking AS " +
		   			"SELECT travelerID, firstname || ' ' || surname as tname, listingID, startDate "
		    		+ "FROM Traveler NATURAL JOIN Booking;\n"
		   			+ "CREATE VIEW homeownerlisting AS "
		   			+ "SELECT homeownerId, firstname || ' ' || surname as hname, listingID "
		   			+ "FROM Homeowner, Listing WHERE owner = homeownerId;\n"
		   			+ "CREATE VIEW homeownerTraveler AS "
		   			+ "SELECT tname as Traveler, homeownerId as Homeowner, listingID, startDate "
		   			+ "from homeownerlisting natural join travelerbooking;\n"
		   			+ "create view Givenratings as "
		   			+ "select Traveler, Homeowner, avg(rating) as rating "
		   			+ "from homeownerTraveler Z, TravelerRating T "
		   			+ "WHERE Z.listingID = T.listingID AND Z.startDate = T.startDate "
		   			+ "group by traveler, Homeowner, Z.listingID;\n"
		   			+ "create view noRatings as "
		   			+ "(select Traveler, Homeowner from homeownerTraveler) EXCEPT "
		   			+ "(select Traveler,Homeowner from Givenratings);\n"
		   			+ "create view noRatingsTable as "
		   			+ "select Traveler,Homeowner, 0 as rating "
		   			+ "from noRatings;\n"
		   			+ "create view allRatingsTable AS "
		   			+ "(select * from Givenratings) UNION (select * from noRatingsTable);\n"
		   			+ "CREATE VIEW SimilarityPart AS "
		   			+ "select T1.traveler, T1.homeowner as H1, T2.homeowner as H2, T1.rating * T2.rating as mult "
		   			+ "from allRatingsTable T1, allRatingsTable T2 "
		   			+ "where T1.traveler = T2.traveler and T1.homeowner <> T2.homeowner;\n"
		   			+ "CREATE VIEW Result AS select H1, H2, sum(mult) as similarity "
		   			+ "from SimilarityPart group by H1, H2 order by similarity DESC, H2 ASC;\n";
		    stmt.executeUpdate(homeowner_query);
		    String queryString = "SELECT H2, similarity FROM Result WHERE H1 = " 
		    						+ homeownerID + "AND similarity <> 0;";
		    rs = stmt.executeQuery(queryString);
		    int i = 0;
		    double tenthSimilarity = 0;
		    while (i < 10 && rs.next()) {
		      int homeownerIDNumber = rs.getInt("H2");
		      double similarities = rs.getDouble("similarity");
		      similars.add(homeownerIDNumber);
		      tenthSimilarity = similarities;
		      i+=1;
		    }

		    while (rs.next()) {
		    	int similarHomeownerID = rs.getInt("H2");
		    	double sim = rs.getDouble("similarity");
		    	if (tenthSimilarity == sim) {
		    		similars.add(similarHomeownerID);
		    	}
		    }
		    stmt.close();
		    return similars;
	   } catch (SQLException e) {
		   e.printStackTrace();
		   System.err.println(e.getClass().getName()+": "+e.getMessage());
	       System.exit(0);
	   }
	   
	   return null;
	    
   }

	/**
	 * Records the fact that a booking request has been accepted by a homeowner.
	 *
	 * If a booking request was made and the corresponding booking has not been
	 * recorded, records it by adding a row to the Booking table, and returns
	 * true. Otherwise, returns false.
	 *
	 * @param requestID
	 *            id of the booking request
	 * @param start
	 *            start date for the booking
	 * @param numNights
	 *            number of nights booked
	 * @param price
	 *            amount paid to the homeowner
	 * @return true if the operation was successful, false otherwise
	 */
	public boolean booking(int requestId, Date start, int numNights, int price) {
		// Implement this method
		SimpleDateFormat sm = new SimpleDateFormat("yyyy-MM-dd");
		String startTime = sm.format(start);
		try {
			stmt = connection.createStatement();
			queryString = "SELECT requestId, listingId, travelerId, numGuests from BookingRequest;";
			pStatement = connection
					.prepareStatement("SET search_path TO bnb,public;");
			pStatement.execute();
			rs = stmt.executeQuery(queryString);
			while (rs.next()) {
				int name = rs.getInt("requestId");
				if (requestId == name) {
					int listingId = rs.getInt("listingId");
					int travelerId = rs.getInt("travelerId");
					int numGuests = rs.getInt("numGuests");
					String sql = "INSERT INTO Booking VALUES(" + listingId
							+ ", '" + startTime + "', " + travelerId + ", "
							+ numNights + ", " + numGuests + ", " + price
							+ ");";
					stmt.executeUpdate(sql);
					return true;
				}
			}
			stmt.close();
			connection.commit();
		} catch (SQLException se) {
			System.err
					.println("SQL Exception." + "<Message>" + se.getMessage());
		}
		return false;
	}

	public static void main(String[] args) {
		// You can put testing code in here. It will not affect our autotester.
		System.out.println("Boo!");
	}

}