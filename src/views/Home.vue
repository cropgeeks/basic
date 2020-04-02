<template>
  <b-container class="container-top">
    <h1>Home</h1>
    <b-card-group deck class="mt-3">
      <b-card
        title="Nursery"
        img-src="~@/assets/plantnursery.jpg"
        img-alt="plant nursery"
      >
        <b-button to="nurseries" varaint="primary">Nurseries</b-button>
      </b-card>
      <b-card
        title="Farm"
        img-src="~@/assets/raspberries-small.jpg"
        img-alt="farm"
      >
        <b-button to="farms" varaint="primary">Farms</b-button>
      </b-card>
      <b-card
        title="Plants"
        img-src="~@/assets/raspberry-plant.jpg"
        img-alt="plants"
      >
        <b-button to="plants" varaint="primary">Plants</b-button>
      </b-card>
    </b-card-group>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'

export default {
  name: 'home',
  data() {
    return {
      nurseries: [],
      plants: [],
      states: [
        { value: 0, text: "Planted"},
        { value: 1, text: "Harvested"},
        { value: 2, text: "Weighted"}
      ],
      show: true
    }
  },
  mounted() {
    web3.eth.getAccounts().then((acc) => {
      this.supplyContract.deployed().then((contract) => {
        contract.getNurseryCount().then((count) => {
          for (var i = 0; i < count; i++) {
            contract.getNursery(i).then((nursery) => {
              this.addNursery(nursery);
            })
          }
        })
      })
    })
  },
  methods: {
    addPlant: function(plant) {
      let p = {
        id: plant[0].toNumber(),
        state: plant[1].toNumber(),
        plantedDate: new Date(plant[2].toNumber() * 1000),
        lat: plant[3].toNumber(),
        long: plant[4].toNumber(),
        nursery: plant[5].toString()
      }

      this.plants.push(p)
    },
    addNursery: function(nursery) {
      let n = {
        id: nursery[0].toNumber(),
        name: nursery[1].toString(),
        lat: nursery[2].toNumber(),
        long: nursery[3].toNumber()
      }

      this.nurseries.push(n);
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
.card-header{
  background-color: rgba(0, 0, 0, 0.000000001);
  border-bottom: 0px;
}
</style>
