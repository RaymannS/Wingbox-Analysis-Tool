async function updateValue() {
    // Get Inputs from HTML Fields
    let combinedInputs = document.querySelectorAll('input[id^="geoInput"], input[id^="loadsInput"]');
    let data = await manageInputs(combinedInputs);

    // Render 3D Plots
    render3DPlot(data);
    
    // Display Values
    document.getElementById("displayValueGeo").textContent = data.geoArray.join(", ");
    document.getElementById("displayValueLoads").textContent = data.loads;
}

async function manageInputs(inputs) {
    // Sort the inputs based on dataset HTML tag order
    inputs = Array.from(inputs).sort((a, b) => {
        return a.dataset.order - b.dataset.order;
    });

    // Map each input into an Array
    let numbers = [];
    for (let i = 0; i < inputs.length; i++) {
        numbers.push(inputs[i].value);
    }

    // Get data from c++ code
    let data = await fetchCalculationData(numbers);
    data = data.result;
    let structData = {
        geo: {
            height: data[0],  // First number
            depth: data[1], // Second  number
        },
        geoArray: data.slice(0, 2),  // First and second numbers
        loads: data[2]  // Last number (third)
    };
    return structData
}

async function fetchCalculationData(numbers) {
    // Send the input to Flask and wait for response
    let response = await fetch('/calculate', {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ numbers: numbers })
    });

    let data = await response.json();  // Get response from Flask
    return data;
}

function positionInputs() { // Function to Move Input Boxes
    let depth = document.getElementById("geoInputDepth");
    let height = document.getElementById("geoInputHeight");
    let loads = document.getElementById("loadsInput");

    depth.style.position = "absolute";
    depth.style.top = "120px";
    depth.style.left = "10px";

    height.style.position = "absolute";
    height.style.top = "160px";
    height.style.left = "10px";

    loads.style.position = "absolute";
    loads.style.top = "200px";
    loads.style.left = "10px";
}

/* ------------------------------------------------------ */
/* ------------------   PLOTTING   ---------------------- */

async function render3DPlot(data) { // Need to make plot look better
    // Need to eventually get rid of axes and lines and ##
    // need to add xyz limits to make sizing good
    // need to make main color gray-black like Matlab new desktop plots
        // blue lines for the wingbox
    const x = [data.geo.height];  // X-axis 
    const y = [data.geo.depth];  // Y-axis
    const z = [data.loads];  // Z-axis

    console.log("Data received for plot:", data); // Can get rid of this in the future

    const trace = {
        x: x,
        y: y,
        z: z,
        mode: 'markers',
        marker: {
            size: 5,
            color: 'rgba(217, 217, 217, 0.14)',
            line: {
                color: 'rgba(217, 217, 217, 0.14)',
                width: 0.5
            },
            opacity: 0.8
        },
        type: 'scatter3d'
    };

    const layout = {
        title: '3D Plot of Wingbox',
        scene: {
            xaxis: { 
                title: 'X Axis', 
                showbackground: true, 
                showline: true,   // Enables border lines
                showgrid: true,   // Shows grid
                zeroline: false,
                linecolor: 'black', // Border color
                linewidth: 3       // Border thickness
            },
            yaxis: { 
                title: 'Y Axis', 
                showbackground: true, 
                showline: true, 
                showgrid: true, 
                zeroline: false,
                linecolor: 'black', 
                linewidth: 3
            },
            zaxis: { 
                title: 'Z Axis', 
                showbackground: true, 
                showline: true, 
                showgrid: true, 
                zeroline: false,
                linecolor: 'black', 
                linewidth: 3
            }
        },
        autosize: true,  // Allow auto-sizing
        margin: { l: 0, r: 0, b: 0, t: 50 }, // Minimize extra margins
        responsive: true  // Ensure it resizes properly
    };

    Plotly.newPlot('my3DPlot', [trace], layout, { responsive: true });
}


/* ------------------------------------------------------ */

// Main Constructor
(async function main() {
    positionInputs();
    await updateValue();
})();
