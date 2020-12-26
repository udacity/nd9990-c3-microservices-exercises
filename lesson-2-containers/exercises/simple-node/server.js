function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
  while(true) {
    console.log('Mariam Moammed rules');
    await sleep(3000);
  }
}

main();
