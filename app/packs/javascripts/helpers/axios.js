import axios from 'axios';
import csrf from 'helpers/csrf';

export default axios.create({
  headers: Object.assign(
    csrf().headers,
    { 'X-Requested-With': 'XMLHttpRequest' }
  )
});
