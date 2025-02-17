async function updateValue() {
    // Get Inputs from HTML Fields
    let combinedInputs = document.querySelectorAll('input[id="geoInput"], input[id="loadsInput"]');
    let data = await manageInputs(combinedInputs);
    
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

/* ------------------------------------------------------ */

// Main Constructor
(async function main() {
    await updateValue();
})();
