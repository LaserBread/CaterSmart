/*======== TURN INTO DELETE WHEN SHIFT HELD =================================*/
// Turn edit buttons into delete buttons while the shift key is held down
var shiftKey = false;
var hoveredButton = null;


function editbutton_makeDelete(){
    if(hoveredButton === null){
        return;
    }
    hoveredButton.classList.add("deletebutton")
    hoveredButton.getElementsByTagName("span")[0].textContent = "delete";
}

function editbutton_makeEdit(){
    if(hoveredButton === null){
        return;
    }
    hoveredButton.getElementsByTagName("span")[0].textContent = "edit";
    hoveredButton.classList.remove("deletebutton");
}

document.addEventListener("keydown", function(event){
    if(event.key === "Shift"){
        shiftKey = true;
        editbutton_makeDelete()
    }
});

document.addEventListener("keyup", function(event){
    if(event.key === "Shift"){
        shiftKey = false;
        editbutton_makeEdit(hoveredButton);
    }
});

window.onload = function(){
document.getElementById("mainlist").addEventListener("mouseover", function(event){
    if (event.target.classList.contains("editbutton")) {
        hoveredButton = event.target;
        if (shiftKey) {
            editbutton_makeDelete(hoveredButton);
        }
    }
});

document.getElementById("mainlist").addEventListener("mouseout", function(event){
    if (event.target.classList.contains("editbutton")) {
        if (!event.relatedTarget || !event.target.contains(event.relatedTarget)){
            editbutton_makeEdit(hoveredButton);
            hoveredButton = null;
        }
    }
}), true;

}
