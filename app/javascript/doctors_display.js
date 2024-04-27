console.log("linked");
$(document).ready(function () {
    console.log("$ is working");
    $("#submit-btn").on("click", function (e) {
        console.log("SUBMIT BTN WORKING");
        e.preventDefault();
        var formData = new FormData($("#doctor_register_form")[0]); 
        var fileInput = $("#doctor_picture")[0];
        if (fileInput.files && fileInput.files[0]) {
            formData.append('doctor_picture', fileInput.files[0]);
        }
        $.ajax({
            url: `http://localhost:3000/manage_doctors`,
            method: "POST",
            data: formData, 
            dataType: "html",
            processData: false, 
            contentType: false,
            success: function (result) {
                console.log(result); 
                const html= `<table style="background-color:blue">
                <tbody>
                    ${result}
                </tbody>
             </table>`   
                $("#display-doctors-div").append(html);
            },
        });
    });
 
   
$("#display-doctors-div").on("click", ".delete-button", function(event) {
    event.preventDefault();
    var deleteButton = $(this); 

    var docObject = deleteButton.data("doc");
    const doctor_id = docObject.user_id;
    console.log(doctor_id);

    $.ajax({
        url: `http://localhost:3000/manage_doctors/${doctor_id}`,
        method: "DELETE",
        dataType: "html",
        processData: false,
        contentType: false, 
        success: function (data) {
            deleteButton.closest("tr").remove();
            event.preventDefault();
            console.log("Doctor deleted successfully!");
        },
        error: function(jqXHR, textStatus, errorThrown) {
            console.error("Error deleting doctor:", textStatus, errorThrown); 
        }
    });
});

      

});