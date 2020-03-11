<template>
  <b-container>
    <h1>Nursery</h1>
    <div class="row" v-if="nursery !== null">
      <div class="col">
        <div class="row">
          <h2>{{ nursery.name }}</h2>
        </div>
        <div class="row">
          <p>{{ nursery.description }}</p>
        </div>
        <div v-if="isNurseryOwner">
          <div class="row">
            <p>Propogated plants</p>
          </div>
          <div class="row">
            <b-table :items="propogated"></b-table>
          </div>
          <div class="row" >
            <p>Purcahsed &amp; Ready for dispatch</p>
          </div>
          <div class="row">
            <b-table :items="purchased"></b-table>
          </div>
        </div>
        <div class="row" v-if="isFarmer">
          <div class="col">
            <div class="row">
              <h4>Buy plants</h4>
            </div>
            <div class="row">
              <p>Variety: Glen Moy</p>
            </div>
            <div class="row">
              <p>{{ stock }} in stock</p>
            </div>
            <b-form inline>
              <label for="quantity">Number of plants</label>
              <b-form-input class="mb-2 mr-sm-2 ml-sm-2 mb-sm-0" id="quantity" type="number" :min="1" :max="stock" v-model="quantity"></b-form-input>
              <button @click="orderPlants" class="btn btn-primary" type="submit">Submit order</button>
            </b-form>
          </div>
        </div>
        <div class="row mt-3">
          <b-button @click="propogatePlant" variant="primary" v-if="isNurseryOwner">Propogate plant</b-button>
        </div>
      </div>
    </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'

export default {
  name: 'home',
  data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      nursery: null,
      plants: [],
      propogated: [],
      purchased: [],
      states: [ 'Propogated', 'Purchased', 'Dispatched', 'Received', 'Planted'],
      isNurseryOwner: false,
      isFarmer: false,
      stock: 0,
      quantity: 1
    }
  },
  mounted() {
    web3.eth.getAccounts().then((acc) => {
      this.defaultAccount = acc[0]
      web3.eth.defaultAccount = acc[0]

      this.supplyContract = TruffleContract(Supply)
      
      this.supplyContract.setProvider(this.w3.currentProvider)
      this.supplyContract.defaults({from: this.w3.eth.defaultAccount})

      // Handle account changes
      web3.currentProvider.publicConfigStore.on('update', (update) => {
        const newAddress = update.selectedAddress;
        this.defaultAccount = newAddress;
        web3.eth.defaultAccount = newAddress;
        this.supplyContract.defaults({from: this.w3.eth.defaultAccount})
      });

      this.supplyContract.deployed().then((contract) => {
        // Retrieve nursery info
        contract.getNursery(this.$route.params.nurseryId).then((n) => {
          this.nursery = {
            id: n[0].toNumber(),
            name: n[1].toString(),
            lat: n[2].toNumber(),
            long: n[3].toNumber(),
            description: n[4].toString(),
            address: n[5]
          }
        })

        // Get plant info for nursery
        contract.getPlantCount().then((count) => {
          for (var i =0; i < count; i++)
          contract.getPlant(i).then((plant) => {
            this.addPlant(plant)
          })
          .then(() => {
            this.stock = this.propogated.length;
          })
        })

        this.isNurseryOwner = false;
        this.isFarmer = false;

        // Check if the selected account is the nursery owner
        contract.isNurseryOwner().then(isOwner => {
          this.isNurseryOwner = isOwner;
        })

        // Check if the selected account is the nursery owner
        contract.isFarmer().then(isFarmer => {
          this.isFarmer = isFarmer;
        })
      })
    })
  },
  watch: {
    defaultAccount: function() {
      this.isNurseryOwner = false;
      this.isFarmer = false;

      this.supplyContract.deployed().then((contract) => {
        contract.isNurseryOwner().then(isOwner => {
          this.isNurseryOwner = isOwner;
        })
        contract.isFarmer().then(isFarmer => {
          this.isFarmer = isFarmer;
        })
      })
    }
  },
  methods: {
    propogatePlant() {
      web3.eth.getAccounts().then((acc) => {
        this.defaultAccount = acc[0]
        web3.eth.defaultAccount = acc[0]

        this.supplyContract = TruffleContract(Supply)
        
        this.supplyContract.setProvider(this.w3.currentProvider)
        this.supplyContract.defaults({from: this.w3.eth.defaultAccount})

        this.supplyContract.deployed().then((contract) => {
          let date = (new Date()).getTime();
          let timestamp = Math.floor(date / 1000);
          contract.propogatePlant(timestamp);
        })
      })
    },
    addPlant: function(plant) {
      let p = {
        id: plant[0].toNumber(),
        state: this.states[plant[1].toNumber()],
        plantedDate: new Date(plant[2].toNumber() * 1000),
        lat: plant[3].toNumber(),
        long: plant[4].toNumber(),
        nursery: plant[5].toString(),
        variety: plant[6].toString(),
        address: plant[7].toString()
      }
      if (p.nursery === this.nursery.name && p.state === 'Propogated') {
        this.propogated.push(p)
      }
      else if (p.nursery === this.nursery.name && p.state === 'Purchased') {
        this.purchased.push(p);
      }
    },
    orderPlants: function() {
      const ordered = this.propogated.slice(0, this.quantity).map(p => p.id);
      this.propogated = this.propogated.slice(this.quantity);

      let date = (new Date()).getTime();
      let timestamp = Math.floor(date / 1000);

      this.supplyContract.deployed().then((contract) => {
        contract.orderPlants(ordered, this.nursery.address, timestamp)
      })
    }
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
