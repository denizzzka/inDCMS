module inDCMS.MySQL;
import mysql.connection;
import std.stdio;
import std.string;
import std.datetime;
import std.variant;

class MySQL
{
	private string settingsStrMySQL = "host=localhost;port=3306;user=testUser;pwd=;db=testDB";
	private Connection connection;

	this(string settingsStrMySQL)
	{
		this.settingsStrMySQL = settingsStrMySQL;
	}

	public void connect()
	{
		try
		{
			version(UseConnPool)
			{
				import mysql.db;
				auto mdb = new MysqlDB(setStrMySQL);
				connection = mdb.lockConnection();
			}
			else
			{
				connection = new Connection(this.settingsStrMySQL);
			}
			writeln("The connection to MySQL is successfully");
		}
		catch ( MySQLException e )
		{
			writeln("Error MySQL: ", e.toString());
			connection.close();
		}
	}

	public Connection getConnection()
	{
		return connection;
	}
	alias getCtn = getConnection;
	
	public void setConnection(Connection MySQLConnection)
	{
		this.connection = MySQLConnection;
	}

	// prepends backslashes to the following characters: \x00, \n, \r, \, ', " and \x1a
	public string escapeStr (string str)
	{
		str = str.replace("\\", "\\\\")
			.replace("\n", "\\n")
			.replace("\r", "\\r")
			.replace("'", "\\'")
			.replace("\"", "\\\"")
			.replace("\x00", "\\x00")
			.replace("\x1a", "\\x1a");
		return str;
	}

	public void bind(T)(ref Command cmd, ushort index, ref T value)
	{
		static if(is(T==typeof(null)))
			cmd.setNullParam(index);
		else
			cmd.bindParameter(value, index);
	}
	
	public void bindAll(Params...)(ref Command cmd, ref Params params)
	{
		foreach(i, ref param; params)
			cmd.bind(i, param);
	}
	
	public Command prepare(string sql)
	{
		auto cmd = Command(connection);
		cmd.sql = sql;
		cmd.prepare();
		return cmd;
	}

	public ResultSet query()(Command cmd)
	{
		return cmd.execPreparedResult();
	}
	
	public ResultSet query()(string sql)
	{
		auto cmd = Command(connection);
		cmd.sql = sql;
		return cmd.execSQLResult();
	}
	
	public ResultSet query(Params...)(string sql, ref Params params)
	{
		auto cmd = connection.prepare(sql);
		cmd.bindAll(params);
		return cmd.query();
	}

	public Row querySingle()(Command cmd)
	{
		return cmd.query()[0];
	}

	public Row querySingle()(string sql)
	{
		return query(sql)[0];
	}
	
	public Row querySingle(Params...)(string sql, ref Params params)
	{
		return query(sql, params)[0];
	}
	
	public Variant queryScalar()(string sql)
	{
		return query(sql)[0][0];
	}
	
	public Variant queryScalar(Params...)(string sql, ref Params params)
	{
		return query(sql, params)[0][0];
	}

	/// Convert a Timestamp to DateTime
	DateTime toDateTime(Timestamp value) pure
	{
		auto x = value.rep;
		int second = cast(int) (x%100);
		x /= 100;
		int minute = cast(int) (x%100);
		x /= 100;
		int hour   = cast(int) (x%100);
		x /= 100;
		int day    = cast(int) (x%100);
		x /= 100;
		int month  = cast(int) (x%100);
		x /= 100;
		int year   = cast(int) (x%10000);
		
		return DateTime(year, month, day, hour, minute, second);
	}
	
	// close of connection
	public void close()
	{
		connection.close();
	}
	~this()
	{
		this.close();
	}
}

