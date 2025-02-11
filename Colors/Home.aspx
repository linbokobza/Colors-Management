<%@ Page Language="vb" AutoEventWireup="false" CodeFile="Home.aspx.vb" Inherits="home" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Color Management</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
        <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css"/>
    <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {

            //show the colors
            loadColors()

            //event listener - add color
            $("#btnAdd").click(function () {
              
                if (!$("#colorPicker").val()) {
                    alert("נא לבחור צבע", false);
                    return;
                }

                if (!$("#txtColorName").val()) {
                    alert("נא להזין שם ", false);
                    return;
                }

                if (!$("#txtPrice").val() || isNaN($("#txtPrice").val())) {
                    alert("נא להזין מחיר תקין", false);
                    return;
                }

                //Checking if it's an edit/add event
                const isEditing = $(this).data("editing-color-id") !== undefined;

                const colorData = {
                    ColorID: $("#colorPicker").val(),
                    ColorName: $("#txtColorName").val(),
                    Price: parseFloat($("#txtPrice").val()),
                    Available: $("#chkAvailable").is(":checked")
                };

                if (isEditing) {
                    colorData.OldColorID = $(this).data("editing-color-id");
                }
                addColor(colorData, isEditing)
            });

            //event listener - edit color
            $(document).on("click", ".edit-color", function () {
                const colorID = $(this).data("color-id");
                editColor(colorID);
            });

            // event listener - delete color
            $(document).on("click", ".delete-color", function () {
                const colorID = $(this).data("color-id");

                if (!confirm("האם אתה בטוח שאתה רוצה למחוק את הצבע הזה?")) return;
                deleteColor(colorID);
            });

            //Bonus: enable dragging colors
            $("#colorsTableBody").sortable({
                handle: "td:not(:last-child)", 
                cursor: "move",
                axis: "y",
                update: function (event, ui) {
                    updateDisplayOrder();
                }
            }).disableSelection();


            function loadColors() {
                $.ajax({
                    type: "POST",
                    url: "home.aspx/GetColors",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        const colors = response.d;
                        const tbody = $("#colorsTableBody");
                        tbody.empty();

                        colors.forEach(function (color, index) {
                            const row = $(`
                        <tr class="hover:bg-zinc-100" data-colorid="${color.ColorID.toString()}">
                            <td class="py-2 px-4 border-b">${color.ColorName}</td>
                            <td class="py-2 px-4 border-b">${color.Price}</td>
                            <td class="py-2 px-4 border-b" style="background-color: ${color.ColorID}">${color.ColorID}</td>
                            <td class="py-2 px-4 border-b">${color.DisplayOrder}</td>
                            <td class="py-2 px-4 border-b">${color.Available ? "✔" : "✘"}</td>
                            <td class="py-2 px-4 border-b">
                                <button class="bg-red-500 text-white px-2 py-1 rounded mr-2 action-button delete-color" data-color-id="${color.ColorID}">מחיקה</button>
                                <button class="bg-blue-500 text-white px-2 py-1 rounded action-button edit-color" data-color-id="${color.ColorID}">עריכה</button>
                            </td>
                        </tr>
                    `);
                            tbody.append(row);

                        });
                    },

                    error: function (xhr, status, error) {
                        alert("שגיאה בטעינת הצבעים: " + error, false);
                    }
                });
            }   

            function addColor(colorData, isEditing) {
                $.ajax({
                    type: "POST",
                    url: isEditing ? "home.aspx/UpdateColor" : "home.aspx/AddNewColor", // choosing the function depending on the event 
                    data: JSON.stringify(colorData),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d.startsWith("שגיאה")) {
                            alert(response.d, false);
                        } else {
                            alert(response.d, true);
                            clearForm();
                            loadColors();

                            // reset the button text
                            $("#btnAdd").text("הוסף צבע").removeData("editing-color-id");
                        }
                    }
                });
            }

            function editColor(colorID) {

                // get color details by colorID
                $.ajax({
                    type: "POST",
                    url: "home.aspx/GetColorByID",
                    data: JSON.stringify({ ColorID: colorID }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        const color = response.d;

                        $("#colorPicker").val(color.ColorID);
                        $("#txtColorName").val(color.ColorName);
                        $("#txtPrice").val(color.Price);
                        $("#chkAvailable").prop("checked", color.Available);

                        // change the button text from add to edit
                        $("#btnAdd").text("עדכן צבע");

                        $("#btnAdd").data("editing-color-id", colorID);
                    },
                    error: function (xhr, status, error) {
                        alert("שגיאה בטעינת הצבע: " + error);
                    }
                });
            }

            function deleteColor(colorID) {
                $.ajax({
                    type: "POST",
                    url: "home.aspx/DeleteColor",
                    data: JSON.stringify({ ColorID: colorID }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d.startsWith("שגיאה")) {
                            alert(response.d);
                        } else {
                            loadColors();
                        }
                    },
                    error: function (xhr, status, error) {
                        alert(error);
                    }
                });
            }

            //Bonus: after dragging te color - updating the order
            function updateDisplayOrder() {

                const newOrder = [];
                $("#colorsTableBody tr").each(function (index) {

                    const colorId = $(this).data("colorid").toString();
                    newOrder.push({
                        ColorID: colorId,
                        DisplayOrder: index + 1
                    });
                });

                $.ajax({
                    type: "POST",
                    url: "home.aspx/UpdateDisplayOrder",
                    data: JSON.stringify({ orders: newOrder }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d.startsWith("שגיאה")) {
                            alert(response.d, false);
                        } else {
                            loadColors(); 
                        }
                    },
                    error: function (xhr, status, error) {
                        alert(error, false);
                    }
                });
            }

            //clear the fields
            function clearForm() {
                $("#colorPicker").val('');
                $("#txtColorName").val('');
                $("#txtPrice").val('');
                $("#chkAvailable").prop('checked', false);
                $("#btnAdd").text("הוסף צבע").removeData("editing-color-id");
            }
        });

    </script>
</head>
<body dir="rtl">
    <div class="container mx-auto p-4">
        <h1 class="text-2xl font-bold mb-4">טבלת צבעים</h1>

        <div id="colorsTableContainer">
            <table class="min-w-full bg-white border border-zinc-300">
                <thead>
                    <tr class="bg-zinc-200">
                        <th class="py-2 px-4 border-b">שם</th>
                        <th class="py-2 px-4 border-b">מחיר</th>
                        <th class="py-2 px-4 border-b">צבע</th>
                        <th class="py-2 px-4 border-b">סדר</th>
                        <th class="py-2 px-4 border-b">זמין?</th>
                        <th class="py-2 px-4 border-b">פעולות</th>
                    </tr>
                </thead>
                <tbody id="colorsTableBody"></tbody>
            </table>
        </div>

       <div class="mt-6 p-4 border border-zinc-300 bg bg-zinc-100">
    <h2 class="text-lg font-semibold mb-2">הוסף צבע חדש</h2>
    <form id="form1" runat="server">
        <div class="space-y-4">
            <div class="flex items-center gap-x-4">
                <label for="colorPicker" class="w-1/4">בחר צבע:</label>
                <input type="color" id="colorPicker" class="border border-zinc-400 p-2 w-20 h-10" />
            </div>

            <div class="flex items-center gap-x-4">
                <label for="txtColorName" class="w-1/4">שם צבע:</label>
                <input type="text" id="txtColorName" class="border border-zinc-400 p-2 flex-grow" />
            </div>

            <div class="flex items-center gap-x-4">
                <label for="txtPrice" class="w-1/4">מחיר:</label>
                <input type="text" id="txtPrice" class="border border-zinc-400 p-2 flex-grow" />
            </div>

            <div class="flex items-center gap-x-2">
                <label for="chkAvailable" class="flex items-center">
                    <input type="checkbox" id="chkAvailable" class="ml-2" />
                    <span>זמין</span>
                </label>
            </div>

            <button type="button" id="btnAdd" class="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600">
                הוסף צבע
            </button>
        </div>
    </form>
</div>

    </div>
</body>
</html>
