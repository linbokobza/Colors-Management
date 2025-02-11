Imports System.Data.SqlClient
Imports System.Web.Services

<System.Web.Script.Services.ScriptService>
Public Class home
    Inherits System.Web.UI.Page

    Private Shared ReadOnly connectionString As String = ConfigurationManager.ConnectionStrings("ColorsDB").ConnectionString

    'connect to the sql server
    Private Shared Function CreateConnection() As SqlConnection
        Dim connection As New SqlConnection(connectionString)
        connection.Open()
        Return connection
    End Function

    'execute query
    Private Shared Function CreateCommand(query As String, connection As SqlConnection) As SqlCommand
        Dim cmd As New SqlCommand(query, connection)
        Return cmd
    End Function

    <WebMethod>
    Public  Function AddNewColor(ByVal ColorID As String, ByVal ColorName As String, ByVal Price As Decimal, ByVal Available As Boolean) As String
        Try
            Dim query As String = "INSERT INTO ColorsStock (ColorID, ColorName, Price, Available, DisplayOrder)
                                             VALUES (@ColorID, @ColorName, @Price, @Available, 
                                           (SELECT ISNULL(MAX(DisplayOrder), 0) + 1 FROM ColorsStock));"

            Using connection = CreateConnection()
                Using cmd = CreateCommand(query, connection)
                    cmd.Parameters.AddWithValue("@ColorID", ColorID)
                    cmd.Parameters.AddWithValue("@ColorName", ColorName)
                    cmd.Parameters.AddWithValue("@Price", Price)
                    cmd.Parameters.AddWithValue("@Available", Available)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            Return "הצבע נוסף לטבלה"
        Catch ex As Exception
            Return "שגיאה: " & ex.Message
        End Try
    End Function

    <WebMethod>
    Public Shared Function GetColors() As List(Of Dictionary(Of String, Object))
        Dim colors As New List(Of Dictionary(Of String, Object))
        Try
            Dim query As String = "SELECT ColorID, ColorName, Price, Available, DisplayOrder FROM ColorsStock ORDER BY DisplayOrder"

            Using connection = CreateConnection()
                Using cmd = CreateCommand(query, connection)
                    Using reader As SqlDataReader = cmd.ExecuteReader()
                        While reader.Read()
                            Dim color As New Dictionary(Of String, Object)
                            color("ColorID") = reader("ColorID")
                            color("ColorName") = reader("ColorName")
                            color("Price") = reader("Price")
                            color("Available") = Convert.ToBoolean(reader("Available"))
                            color("DisplayOrder") = reader("DisplayOrder")
                            colors.Add(color)
                        End While
                    End Using
                End Using
            End Using
        Catch ex As Exception
        End Try
        Return colors
    End Function

    <WebMethod>
    Public Shared Function DeleteColor(ByVal ColorID As String) As String
        Try
            Dim query As String = "
                DECLARE @DeletedOrder INT;
                SELECT @DeletedOrder = DisplayOrder FROM ColorsStock WHERE ColorID = @ColorID;
                DELETE FROM ColorsStock WHERE ColorID = @ColorID;
                UPDATE ColorsStock SET DisplayOrder = DisplayOrder - 1 WHERE DisplayOrder > @DeletedOrder;"

            Using connection = CreateConnection()
                Using cmd = CreateCommand(query, connection)
                    cmd.Parameters.AddWithValue("@ColorID", ColorID)
                    cmd.ExecuteNonQuery()
                End Using
            End Using

            Return "הצבע נמחק בהצלחה"
        Catch ex As Exception
            Return "שגיאה: " & ex.Message
        End Try
    End Function

    <WebMethod>
    Public Shared Function GetColorByID(ByVal ColorID As String) As Dictionary(Of String, Object)
        Dim color As New Dictionary(Of String, Object)
        Try
            Dim query As String = "SELECT ColorID, ColorName, Price, Available FROM ColorsStock WHERE ColorID = @ColorID"

            Using connection = CreateConnection()
                Using cmd = CreateCommand(query, connection)
                    cmd.Parameters.AddWithValue("@ColorID", ColorID)
                    Using reader As SqlDataReader = cmd.ExecuteReader()
                        If reader.Read() Then
                            color("ColorID") = reader("ColorID")
                            color("ColorName") = reader("ColorName")
                            color("Price") = reader("Price")
                            color("Available") = Convert.ToBoolean(reader("Available"))
                        End If
                    End Using
                End Using
            End Using
        Catch ex As Exception
            Throw ex
        End Try
        Return color
    End Function

    <WebMethod>
    Public Shared Function UpdateColor(ByVal OldColorID As String, ByVal ColorID As String, ByVal ColorName As String, ByVal Price As Decimal, ByVal Available As Boolean) As String
        Try
            Dim query As String = "UPDATE ColorsStock SET ColorID = @NewColorID, ColorName = @ColorName, Price = @Price, Available = @Available WHERE ColorID = @OldColorID"

            Using connection = CreateConnection()
                Using cmd = CreateCommand(query, connection)
                    cmd.Parameters.AddWithValue("@OldColorID", OldColorID)
                    cmd.Parameters.AddWithValue("@NewColorID", ColorID)
                    cmd.Parameters.AddWithValue("@ColorName", ColorName)
                    cmd.Parameters.AddWithValue("@Price", Price)
                    cmd.Parameters.AddWithValue("@Available", Available)
                    Dim rowsAffected = cmd.ExecuteNonQuery()
                    If rowsAffected > 0 Then
                        Return "הצבע עודכן בהצלחה!"
                    Else
                        Return "הצבע לא נמצא"
                    End If
                End Using
            End Using
        Catch ex As Exception
            Return "שגיאה: " & ex.Message
        End Try
    End Function

    <WebMethod>
    Public Shared Function UpdateDisplayOrder(orders As List(Of Dictionary(Of String, Object))) As String
        Try
            Dim query As String = "UPDATE ColorsStock SET DisplayOrder = @DisplayOrder WHERE ColorID = @ColorID"

            Using connection = CreateConnection()
                For Each item In orders
                    Using cmd = CreateCommand(query, connection)
                        cmd.Parameters.AddWithValue("@DisplayOrder", item("DisplayOrder"))
                        cmd.Parameters.AddWithValue("@ColorID", item("ColorID"))
                        cmd.ExecuteNonQuery()
                    End Using
                Next
            End Using

            Return "סדר ההצגה עודכן בהצלחה"
        Catch ex As Exception
            Return "שגיאה: " & ex.Message
        End Try
    End Function

End Class
